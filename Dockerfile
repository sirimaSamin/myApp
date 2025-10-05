# ใช้ base image ที่รองรับ Python
FROM python:3.9-slim

# ตั้ง working directory ภายใน container
WORKDIR /app

# คัดลอกไฟล์ requirements.txt เข้ามาใน container
COPY requirements.txt /app/

# ติดตั้ง dependencies ที่ระบุใน requirements.txt
RUN pip install -r requirements.txt

# คัดลอกโค้ดทั้งหมดจากเครื่อง host เข้ามาใน container
COPY . /app/

# เปิด port 80
EXPOSE 80

# คำสั่งในการรัน Flask app
CMD ["flask", "run", "--host=0.0.0.0"]
