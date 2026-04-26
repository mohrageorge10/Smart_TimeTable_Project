from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional
from ortools.sat.python import cp_model
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="Time Table Generator API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class CourseItem(BaseModel):
    name: str
    person: str
    students: int
    available_days: Optional[List[str]] = []
    type: str
    batch: Optional[str] = "general"    # الدفعة/السنة الدراسية
    section: Optional[str] = None       # Section 1..10 / Grade 1..6 / None = محاضرة عامة

class RoomInfo(BaseModel):
    capacity: int
    type: str

class ScheduleRequest(BaseModel):
    items: List[CourseItem]
    days: List[str]
    timeslots: List[str]
    rooms_info: Dict[str, RoomInfo]

# FIX 1: mapping صريح بين نوع المادة ونوع القاعة المطلوبة
# For School: "Lecture" and "Lab" and "Activity" all go to any room
# (School rooms are typed as "Room", "Lab", "Classroom" — not "Lecture Hall")
# So we use "" (any room) for School item types that would otherwise fail
ITEM_TO_ROOM_TYPE = {
    "lecture":          "",   # School Lecture → any room (Classroom/Room/Lab)
    "section":          "lab",
    "lab":              "lab",
    "computer lab":     "computer lab",
    "workshop":         "",
    "keynote":          "",
    "panel discussion": "",
    "morning shift":    "",
    "night shift":      "",
    "emergency":        "",
    "clinic":           "",
    "primary":          "",
    "secondary":        "",
    "preparatory":      "",
    "activity":         "",
    "break":            "",
}

# College-specific: override Lecture → Lecture Hall only when room has type "Lecture Hall"
# We handle this by checking context in solve_schedule instead of a global map

def get_required_room_type(item_type: str) -> str:
    """إرجاع نوع القاعة المطلوبة لنوع المادة، أو '' لو أي قاعة تنفع"""
    return ITEM_TO_ROOM_TYPE.get(item_type.lower().strip(), "")

def room_matches_type(room_type: str, required: str) -> bool:
    if not required:
        return True
    if room_type.lower().strip() == "any":
        return True   # virtual room matches everything (Hospital)
    return required in room_type.lower().strip()


def has_room_of_type(rooms_info, required_type):
    """Check if any room of the required type exists."""
    if not required_type:
        return True
    return any(required_type in r["type"].lower() for r in rooms_info.values())

def get_effective_room_type(item_type: str, rooms_info: dict) -> str:
    """
    Returns the required room type for an item, but falls back to '' (any)
    if no room of that type exists — so the solver stays feasible.
    """
    raw = ITEM_TO_ROOM_TYPE.get(item_type.lower().strip(), "")
    if raw and not has_room_of_type(rooms_info, raw):
        return ""   # graceful fallback: use any available room
    return raw

def solve_schedule(items, days, timeslots, rooms, rooms_info):
    model = cp_model.CpModel()
    x = {}

    for i in range(len(items)):
        for d in range(len(days)):
            for t in range(len(timeslots)):
                for r in range(len(rooms)):
                    x[(i, d, t, r)] = model.new_bool_var(f'v_{i}_{d}_{t}_{r}')

    wasted_space_costs = []

    for i, item in enumerate(items):
        item_type = item.get("type", "Lecture")
        required_room_type = get_effective_room_type(item_type, rooms_info)

        # معالجة الأيام المتاحة
        allowed_days = item.get('available_days', [])
        if not allowed_days:
            allowed_days_indices = list(range(len(days)))
        else:
            allowed_days_indices = [days.index(day) for day in allowed_days if day in days]

        # كل مادة لازم تنزل مرة واحدة بالظبط
        model.add_exactly_one(
            x[(i, d, t, r)]
            for d in range(len(days))
            for t in range(len(timeslots))
            for r in range(len(rooms))
        )

        for d in range(len(days)):
            if d not in allowed_days_indices:
                for t in range(len(timeslots)):
                    for r in range(len(rooms)):
                        model.add(x[(i, d, t, r)] == 0)
                continue

            for t in range(len(timeslots)):
                for r_idx, room in enumerate(rooms):
                    r_data = rooms_info[room]

                    # FIX 1: تحقق من نوع القاعة باستخدام الـ mapping الصريح
                    if not room_matches_type(r_data["type"], required_room_type):
                        model.add(x[(i, d, t, r_idx)] == 0)
                        continue

                    # FIX 3: تجاهل شرط السعة لو students = 0
                    students = item.get('students', 0)
                    if students > 0 and r_data["capacity"] < students:
                        model.add(x[(i, d, t, r_idx)] == 0)
                    else:
                        if students > 0:
                            wasted = r_data["capacity"] - students
                            wasted_space_costs.append(wasted * x[(i, d, t, r_idx)])

    # شرط: القاعة الواحدة فيها مادة واحدة في نفس الوقت
    for d in range(len(days)):
        for t in range(len(timeslots)):
            for r in range(len(rooms)):
                model.add_at_most_one(x[(i, d, t, r)] for i in range(len(items)))

    # شرط: الدكتور/المدرس ميكونش في مكانين في نفس الوقت
    for d in range(len(days)):
        for t in range(len(timeslots)):
            persons = set(item['person'] for item in items)
            for person_name in persons:
                person_indices = [idx for idx, itm in enumerate(items) if itm['person'] == person_name]
                if person_indices:
                    model.add_at_most_one(
                        x[(idx, d, t, r)]
                        for idx in person_indices
                        for r in range(len(rooms))
                    )

    # ══════════════════════════════════════════════════════════
    # قاعدة التضارب الصحيحة للـ batch + section
    #
    # المنطق:
    #   - طلاب Section 1 موجودون في:
    #       (1) المحاضرات العامة (general) لدفعتهم
    #       (2) سكشن Section 1 تحديداً
    #   - إذن: أي محاضرة عامة + أي سكشن من نفس الدفعة
    #     لا يمكن تجدولهما في نفس الوقت لأن الطلاب موجودون في الاثنين
    # ══════════════════════════════════════════════════════════
    batches = set(item.get('batch', 'general') for item in items)
    for batch in batches:
        is_general = lambda item: (
            item.get('batch', 'general') == batch and
            (item.get('section') is None or
             'general' in str(item.get('section', '')).lower())
        )
        is_section = lambda item, sec: (
            item.get('batch', 'general') == batch and
            item.get('section') == sec and
            'general' not in str(item.get('section', '')).lower()
        )

        general_indices = [i for i, item in enumerate(items) if is_general(item)]

        sections_in_batch = set(
            item.get('section') for item in items
            if item.get('batch', 'general') == batch
            and item.get('section')
            and 'general' not in str(item.get('section', '')).lower()
        )

        # 1. محاضرتان عامتان لنفس الدفعة → لا تتزامنان
        if len(general_indices) > 1:
            for d in range(len(days)):
                for t in range(len(timeslots)):
                    model.add_at_most_one(
                        x[(i, d, t, r)]
                        for i in general_indices
                        for r in range(len(rooms))
                    )

        for section in sections_in_batch:
            section_indices = [i for i, item in enumerate(items) if is_section(item, section)]

            # 2. سكشنان لنفس الـ section → لا يتزامنان (نادر لكن ممكن)
            if len(section_indices) > 1:
                for d in range(len(days)):
                    for t in range(len(timeslots)):
                        model.add_at_most_one(
                            x[(i, d, t, r)]
                            for i in section_indices
                            for r in range(len(rooms))
                        )

            # 3. ✅ الإصلاح الجوهري:
            #    محاضرة عامة + سكشن من نفس الدفعة → لا يتزامنان
            #    لأن طلاب السكشن موجودون في المحاضرة العامة أيضاً
            combined = general_indices + section_indices
            if len(combined) > 1:
                for d in range(len(days)):
                    for t in range(len(timeslots)):
                        model.add_at_most_one(
                            x[(i, d, t, r)]
                            for i in combined
                            for r in range(len(rooms))
                        )

    if wasted_space_costs:
        model.Minimize(sum(wasted_space_costs))

    solver = cp_model.CpSolver()
    solver.parameters.max_time_in_seconds = 30.0
    status = solver.solve(model)

    solved_assignments = []
    if status in (cp_model.OPTIMAL, cp_model.FEASIBLE):
        for i, item in enumerate(items):
            for d in range(len(days)):
                for t in range(len(timeslots)):
                    for r_idx, r_name in enumerate(rooms):
                        if solver.value(x[(i, d, t, r_idx)]) == 1:
                            res = item.copy()
                            res.update({"day": days[d], "slot": timeslots[t], "room": r_name})
                            solved_assignments.append(res)
        return solved_assignments, True
    else:
        return [], False


@app.post("/generate-schedule")
def generate_schedule_api(request: ScheduleRequest):
    items_list = [item.model_dump() for item in request.items]
    rooms_dict = {k: v.model_dump() for k, v in request.rooms_info.items()}
    rooms_list = list(rooms_dict.keys())

    assignments, success = solve_schedule(
        items=items_list,
        days=request.days,
        timeslots=request.timeslots,
        rooms=rooms_list,
        rooms_info=rooms_dict
    )

    if success:
        return {"status": "success", "schedule": assignments}
    else:
        raise HTTPException(
            status_code=400,
            detail="The AI could not find a solution. Please check: (1) rooms capacity is enough for students count, (2) room types match course types, (3) there are enough time slots for all courses."
        )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
