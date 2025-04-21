from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Annotated, Any
from bson.objectid import ObjectId
from pydantic_core import core_schema

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __get_pydantic_json_schema__(cls, _schema_generator, _field_schema):
        return {"type": "string"}
    
    @classmethod
    def __get_pydantic_core_schema__(cls, _source_type, _handler):
        return core_schema.union_schema([
            core_schema.is_instance_schema(ObjectId),
            core_schema.chain_schema([
                core_schema.str_schema(),
                core_schema.no_info_plain_validator_function(
                    lambda s: ObjectId(s)
                )
            ])
        ])

class UserModel(BaseModel):
    # id: Optional[PyObjectId] = Field(default=None, alias="_id") #สามารถใช้ได้ทั้ง id และ _id
    user_id: str
    username: str = Field(...) #(...) คือการที่ใน field ข้อมูลนั้นบังคับต้องมีค่า
    gender: str = Field(...) #(...) คือการที่ใน field ข้อมูลนั้นบังคับต้องมีค่า
    image_url: Optional[str] = None
    is_deleted: bool = False
    created_at: str = datetime.utcnow().isoformat()
    update_at: str = datetime.utcnow().isoformat()

    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str},
        json_schema_extra={
            "example": {
                "username": "johndoe",
                "gender": "Male",
                "image_url": "https://example.com/images/profile.jpg"
            }
        }
    )


class UserUpdateModel(BaseModel):
    user_id: Optional[str] = None
    username: Optional[str] = None
    gender: Optional[str] = None
    image_url: Optional[str] = None
    is_deleted: Optional[bool] = None
    update_at: str = datetime.utcnow().isoformat()

    model_config = ConfigDict(
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str},
        json_schema_extra={
            "example": {
                "username": "johndoe",
                "gender": "Male",
                "image_url": "https://example.com/images/profile.jpg"
            }
        }
    )

# เพิ่มโมเดลสำหรับ Garment
class Garment:
    def __init__(self, user_id, garment_type, garment_image, garment_id=None, created_at=None):
        self.garment_id = garment_id
        self.user_id = user_id
        self.garment_type = garment_type  # "upper", "lower", "dress"
        self.garment_image = garment_image  # URL จาก Firebase Storage
        self.created_at = created_at

    @classmethod
    def from_dict(cls, data):
        return cls(
            user_id=data.get("user_id"),
            garment_type=data.get("garment_type"),
            garment_image=data.get("garment_image"),
            garment_id=data.get("_id"),
            created_at=data.get("created_at")
        )

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "garment_type": self.garment_type,
            "garment_image": self.garment_image,
            "created_at": self.created_at
        }
# เพิ่ม model สำหรับ Matching
class MatchingModel(BaseModel):
    id: Optional[PyObjectId] = Field(default=None, alias="_id")
    user_id: str
    garment_top: Optional[str] = None  # อาจเป็น null ถ้าเลือกเฉพาะส่วนล่าง
    garment_bottom: Optional[str] = None  # อาจเป็น null ถ้าเลือกเฉพาะส่วนบน
    matching_result: str
    matching_detail: Optional[str] = None
    matching_date: Optional[str] = None
    is_favorite: Optional[bool] = False

    model_config = ConfigDict(
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str},
        json_schema_extra={
            "example": {
                "user_id": "user123",
                "garment_top": "top123",
                "garment_bottom": "bottom123",
                "matching_result": "Casual Style",
                "matching_date": "2023-01-01T12:00:00",
                "is_favorite": False
            }
        }
    )

# เพิ่มโมเดลสำหรับการอัปเดตสถานะ favorite
class FavoriteModel(BaseModel):
    matching_id: str
    user_id: str
    is_favorite: Optional[bool] = True

    model_config = ConfigDict(
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str},
        json_schema_extra={
            "example": {
                "is_favorite": True
            }
        }
    )
