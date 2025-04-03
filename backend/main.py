from fastapi import FastAPI, APIRouter, HTTPException
from configuration import user_collection, garment_collection
from database.schemas import all_users, user_data
from database.models import UserModel, UserUpdateModel, Garment
from bson.objectid import ObjectId
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
 
app = FastAPI()
 
router = APIRouter()

@router.get("/")
async def home():
    return {"message": "Welcome to FastAPI"}

# User Endpoints
@router.get("/users")
async def get_all_users():
    """ดึงข้อมูลผู้ใช้ทั้งหมด"""
    data = user_collection.find({"is_deleted": False})
    return all_users(data)

@router.get("/users/{user_id}")
async def get_user(user_id: str):
    """ดึงข้อมูลผู้ใช้ตาม ID"""
    try:
        id = ObjectId(user_id)
        user = user_collection.find_one({"_id": id, "is_deleted": False})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user_data(user)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@router.post("/users/create")
async def create_user(new_user: UserModel):
    """สร้างผู้ใช้ใหม่"""
    try:
        user_dict = dict(new_user)
        if "_id" in user_dict:
            del user_dict["_id"]
        # user_dict["created_at"] = int(datetime.timestamp(datetime.now()))
        # user_dict["updated_at"] = user_dict["created_at"]
        # user_dict["is_deleted"] = False
        
        resp = user_collection.insert_one(user_dict)
        return {"status_code": 200, "id": str(resp.inserted_id), "message": "User created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

# @router.put("/users/{user_id}")
# async def update_user(user_id: str, updated_user: UserUpdateModel):
#     """อัปเดตข้อมูลผู้ใช้"""
#     try:
#         id = ObjectId(user_id)
#         existing_user = user_collection.find_one({"_id": id, "is_deleted": False})
#         if not existing_user:
#             raise HTTPException(status_code=404, detail="User not found")
        
#         # กรองเฉพาะฟิลด์ที่มีค่า
#         update_data = {k: v for k, v in dict(updated_user).items() if v is not None}
#         update_data["updated_at"] = datetime.timestamp(datetime.now())
        
#         user_collection.update_one({"_id": id}, {"$set": update_data})
#         return {"status_code": 200, "message": "User updated successfully"}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@router.delete("/users/{user_id}")
async def delete_user(user_id: str):
    """ลบผู้ใช้ (soft delete)"""
    try:
        id = ObjectId(user_id)
        existing_user = user_collection.find_one({"_id": id, "is_deleted": False})
        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")
        
        user_collection.update_one({"_id": id}, {"$set": {"is_deleted": True}})
        return {"status_code": 200, "message": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@router.get("/users/check/{firebase_uid}")
async def check_user_exists(firebase_uid: str):
    """ตรวจสอบว่ามีผู้ใช้ที่มี Firebase UID นี้อยู่แล้วหรือไม่"""
    try:
        print(f"Checking if user exists with firebase_uid: {firebase_uid}")
        user = user_collection.find_one({"user_id": firebase_uid, "is_deleted": False})
        
        if user:
            print(f"User found: {user}")
            # แปลง ObjectId เป็น string เพื่อให้ส่งกลับเป็น JSON ได้
            user["_id"] = str(user["_id"])
            return {"exists": True, "user_data": user}
        
        print(f"No user found with firebase_uid: {firebase_uid}")
        return {"exists": False}
    except Exception as e:
        print(f"Error checking user exists: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@router.put("/users/update-by-firebase-uid/{firebase_uid}")
async def update_user_by_firebase_uid(firebase_uid: str, updated_user: UserUpdateModel):
    """อัปเดตข้อมูลผู้ใช้โดยใช้ Firebase UID"""
    try:
        existing_user = user_collection.find_one({"user_id": firebase_uid, "is_deleted": False})
        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # กรองเฉพาะฟิลด์ที่มีค่า
        update_data = {k: v for k, v in dict(updated_user).items() if v is not None}
        # update_data["updated_at"] = datetime.timestamp(datetime.now())
        
        user_collection.update_one({"user_id": firebase_uid}, {"$set": update_data})
        return {"status_code": 200, "message": "User updated successfully"}
    except Exception as e:
        print(f"Error updating user: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

# Garment endpoints
@router.post("/garments/create")
async def create_garment(garment_data: dict):
    try:
        # ตรวจสอบข้อมูลที่จำเป็น
        if not all(key in garment_data for key in ["user_id", "garment_type", "garment_image"]):
            raise HTTPException(status_code=400, detail="Missing required fields")
        
        # ตรวจสอบประเภทเสื้อผ้า
        if garment_data["garment_type"] not in ["upper", "lower", "dress"]:
            raise HTTPException(status_code=400, detail="Invalid garment type")
        
        # เพิ่มเวลาที่สร้าง
        if "created_at" not in garment_data:
            garment_data["created_at"] = datetime.now().isoformat()
        
        # บันทึกลงใน MongoDB
        result = garment_collection.insert_one(garment_data)
        
        # ส่งคืน ID ของเสื้อผ้าที่สร้าง
        return {"garment_id": str(result.inserted_id), "message": "Garment created successfully"}
    except Exception as e:
        print(f"Error creating garment: {e}")
        raise HTTPException(status_code=500, detail=str(e))

#get_garments_by_type
@router.get("/garments/user/{user_id}/type/{garment_type}")
async def get_garments_by_type(user_id: str, garment_type: str):
    try:
        # ตรวจสอบประเภทเสื้อผ้า
        if garment_type not in ["upper", "lower", "dress"]:
            raise HTTPException(status_code=400, detail="Invalid garment type")
        
        # ค้นหาเสื้อผ้าตามประเภทและ user_id
        garments = garment_collection.find({"user_id": user_id, "garment_type": garment_type})
        
        # แปลงเป็น list และเพิ่ม _id
        result = []
        for garment in garments:
            garment["_id"] = str(garment["_id"])
            result.append(garment)
        
        return result
    except Exception as e:
        print(f"Error getting garments: {e}")
        raise HTTPException(status_code=500, detail=str(e))

#delete_garment
@router.delete("/garments/{garment_id}")
async def delete_garment(garment_id: str):
    try:
        # ลบเสื้อผ้าตาม ID
        result = garment_collection.delete_one({"_id": ObjectId(garment_id)})
        
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Garment not found")
        
        return {"message": "Garment deleted successfully"}
    except Exception as e:
        print(f"Error deleting garment: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# เพิ่ม CORS middleware ให้ถูกต้อง
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ในการผลิตจริง ควรระบุ origins ที่อนุญาตเท่านั้น
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
