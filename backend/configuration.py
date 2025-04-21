from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import certifi


# MongoDB connection string
uri = "mongodb+srv://bundit4me:GJKL246Dy0WSO6IF@cluster0.k6vyy.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Create a new client with explicit TLS/SSL settings
client = MongoClient(
    uri,
    server_api=ServerApi('1'),
    tlsCAFile=certifi.where(),  # Use the certifi CA bundle
    tls=True,
    tlsAllowInvalidCertificates=True  # Instead of ssl_cert_reqs
)

# Add error handling to verify connection
try:
    # Send a ping to confirm a successful connection
    client.admin.command('ping')
    print("Successfully connected to MongoDB!")
except Exception as e:
    print(f"Failed to connect to MongoDB: {e}")

# db = client.todo_db
# collection = db["todo_data"]
db = client.fitchoose
user_collection = db["user_data"]
garment_collection = db["garment_data"]  # เพิ่ม collection สำหรับเก็บข้อมูลเสื้อผ้า
matching_collection = db["matching_data"]  # เพิ่ม collection สำหรับเก็บประวัติการ matching
favorite_collection = db["favorite_data"]  # เพิ่ม collection สำหรับเก็บประวัติการ favorite