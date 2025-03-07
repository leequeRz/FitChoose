from datetime import datetime
from pydantic import BaseModel

class Todo(BaseModel):
   title: str
   description: str
   is_completed: bool = False
   is_deleted: bool = False
   created_at: int = int(datetime.timestamp(datetime.now()))
   update_at: int = int(datetime.timestamp(datetime.now()))