# def individual_data(todo):
#    return{
#       "id": str(todo["_id"]),
#       "title": todo["title"],
#       "description": todo["description"],
#       "status": todo["is_completed"],
#    }

# def all_tasks(todos):
#    return [individual_data(todo) for todo in todos]

# เพิ่มฟังก์ชันสำหรับข้อมูลผู้ใช้
def user_data(user):
   return{
      "id": str(user["_id"]),
      "username": user["username"],
      "gender": user["gender"],
      "image_url": user.get("image_url", None),
   }

def all_users(users):
   return [user_data(user) for user in users]