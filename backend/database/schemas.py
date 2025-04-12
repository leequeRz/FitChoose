# เพิ่มฟังก์ชันสำหรับข้อมูลผู้ใช้
def user_data(user):
   return{
      "id": str(user["_id"]),
      "user_id": user.get("user_id", ""),
      "username": user.get["username"],
      "gender": user.get["gender"],
      "image_url": user.get("image_url", None),
   }

def all_users(users):
   return [user_data(user) for user in users]
