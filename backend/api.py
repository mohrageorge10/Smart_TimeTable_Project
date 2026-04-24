from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional
from ortools.sat.python import cp_model
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# 1. تهيئة تطبيق FastAPI
app = FastAPI(title="Time Table Generator API")

# السماح لفلاتر أو أي موقع ويب إنه يكلم الـ API ده بدون مشاكل (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2. تعريف شكل البيانات اللي هنستقبلها من فلاتر (Models)
class CourseItem(BaseModel):
    name: str
    person: str
    students: int
    available_days: Optional[List[str]] = [] 
    type: str

class RoomInfo(BaseModel):
    capacity: int
    type: str

class ScheduleRequest(BaseModel):
    items: List[CourseItem]
    days: List[str]
    timeslots: List[str]
    rooms_info: Dict[str, RoomInfo]

# 3. دالة الذكاء الاصطناعي (OR-Tools)
def solve_schedule(items, days, timeslots, rooms, rooms_info):
    model = cp_model.CpModel()
    x = {}
    
    # تعريف المتغيرات
    for i in range(len(items)):
        for d in range(len(days)):
            for t in range(len(timeslots)):
                for r in range(len(rooms)):
                    x[(i, d, t, r)] = model.new_bool_var(f'v_{i}_{d}_{t}_{r}')

    wasted_space_costs = []

    for i, item in enumerate(items):
        item_type = item.get("type", "Lecture").lower() 
        
        # معالجة الأيام المتاحة
        allowed_days = item.get('available_days', [])
        if not allowed_days:
            allowed_days_indices = list(range(len(days)))
        else:
            allowed_days_indices = [days.index(day) for day in allowed_days if day in days]
        
        # شرط: كل مادة لازم تنزل مرة واحدة بالظبط
        model.add_exactly_one(x[(i, d, t, r)] 
                              for d in range(len(days)) 
                              for t in range(len(timeslots)) 
                              for r in range(len(rooms)))

        for d in range(len(days)):
            # منع الأيام غير المتاحة
            if d not in allowed_days_indices:
                for t in range(len(timeslots)):
                    for r in range(len(rooms)):
                        model.add(x[(i, d, t, r)] == 0)
                continue
                
            for t in range(len(timeslots)):
                for r_idx, room in enumerate(rooms):
                    r_data = rooms_info[room]
                    room_type = r_data["type"].lower() 
                    
                    # شرط السعة
                    if r_data["capacity"] < item['students']:
                        model.add(x[(i, d, t, r_idx)] == 0)
                    else:
                        wasted = r_data["capacity"] - item['students']
                        wasted_space_costs.append(wasted * x[(i, d, t, r_idx)])
                        
                    # شرط تطابق النوع
                    if "lecture" in item_type and "hall" not in room_type:
                        model.add(x[(i, d, t, r_idx)] == 0)
                    elif "lab" in item_type and "lab" not in room_type:
                        model.add(x[(i, d, t, r_idx)] == 0)

    # شرط: القاعة الواحدة فيها مادة واحدة في نفس الوقت
    for d in range(len(days)):
        for t in range(len(timeslots)):
            for r in range(len(rooms)):
                model.add_at_most_one(x[(i, d, t, r)] for i in range(len(items)))

    # شرط: الدكتور الواحد ميكونش في مكانين في نفس الوقت
    for d in range(len(days)):
        for t in range(len(timeslots)):
            persons = set(item['person'] for item in items)
            for person_name in persons:
                person_items_indices = [idx for idx, itm in enumerate(items) if itm['person'] == person_name]
                if person_items_indices:
                    model.add_at_most_one(x[(idx, d, t, r)] 
                                          for idx in person_items_indices 
                                          for r in range(len(rooms)))

    # ========================================================
    # 👈 التعديل الجديد: منع تداخل المحاضرات لنفس الدفعة
    # شرط: لا يمكن تشغيل أكثر من مادة واحدة في نفس اليوم ونفس الفترة
    # ========================================================
    for d in range(len(days)):
        for t in range(len(timeslots)):
            model.add_at_most_one(x[(i, d, t, r)] for i in range(len(items)) for r in range(len(rooms)))

    # تقليل المساحات المهدرة
    if wasted_space_costs:
        model.Minimize(sum(wasted_space_costs))

    solver = cp_model.CpSolver()
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
        raise HTTPException(status_code=400, detail="The AI could not find a solution (Please ensure there are rooms with sufficient capacity for the students).")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)