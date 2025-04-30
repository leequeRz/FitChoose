# yolo_obj.py
import cv2
import base64
import numpy as np
import requests
from pathlib import Path
from ultralytics import YOLO

#custom weights file
model = YOLO("C:/Users/User/Downloads/ObjectDetection_Model-main/ObjectDetection_Model-main/weight.model/best.pt")

# โฟลเดอร์สำหรับเก็บไฟล์ที่ Crop
output_dir = Path("cropped_images")
output_dir.mkdir(exist_ok=True)

async def download_image(image_url: str) -> np.ndarray:
    """ ดาวน์โหลดรูปจาก URL และแปลงเป็น OpenCV Image """
    response = requests.get(image_url)
    image_np = np.frombuffer(response.content, np.uint8)
    return cv2.imdecode(image_np, cv2.IMREAD_COLOR)

async def process_yolo(task_id: str, image_url: str, server_url: str):
    """ ประมวลผลรูปภาพด้วย YOLO และบันทึก Crop Image พร้อมคืน URL """
    
    # ดาวน์โหลดรูปภาพจาก URL
    img = await download_image(image_url)

    results = model(img, conf=.1)
    detected_objects = []

    print(f"Detected {len(results)} objects")
    for idx, result in enumerate(results):
        for box, cls in zip(result.boxes.xyxy, result.boxes.cls):
            x1, y1, x2, y2 = map(int, box)
            class_name = model.names[int(cls)]
            cropped_img = img[y1:y2, x1:x2]

            # ตั้งชื่อไฟล์สำหรับ Crop Image
            filename = f"{task_id}_{class_name}_{idx}.jpg"
            file_path = output_dir / filename

            # บันทึกไฟล์
            cv2.imwrite(str(file_path), cropped_img)

            # URL ของรูปที่ Crop แล้ว
            cropped_url = f"{server_url}/cropped_images/{filename}"

            # เพิ่มข้อมูลลง Database (หากต้องการ)
            detected_objects.append({
                "class": class_name,
                "cropped_image_url": cropped_url
            })

    return task_id, detected_objects
