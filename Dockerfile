# ใช้ base image ที่รองรับ Python
FROM python:3.8-slim-bullseye

# อัพเดท security packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ตั้ง working directory ภายใน container
WORKDIR /app

# คัดลอกไฟล์ requirements.txt เข้ามาใน container
COPY requirements.txt /app/

# ติดตั้ง dependencies ที่ระบุใน requirements.txt
RUN  pip install --no-cache-dir -r requirements.txt

# คัดลอกโค้ดทั้งหมดจากเครื่อง host เข้ามาใน container
COPY . /app/

# เปิด port 80
EXPOSE 80

# คำสั่งในการรัน Flask app
CMD ["flask", "run", "--host=0.0.0.0","--port=80"]
