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