#!/bin/bash

# ตรวจสอบให้แน่ใจว่าสคริปต์รันด้วยสิทธิ์ของผู้ใช้ root
if [ "$(id -u)" -ne 0 ]; then
  echo "สคริปต์นี้ต้องรันด้วยสิทธิ์ root" >&2
  exit 1
fi

# 1. ดาวน์โหลดไฟล์ติดตั้ง Falcon Sensor
echo "กำลังดาวน์โหลด Falcon Sensor..."
wget -q https://storage.googleapis.com/falcon-sensor.appspot.com/ubuntu/7.16.16903/falcon-sensor_7.16.0-16903_amd64.deb
if [ $? -ne 0 ]; then
  echo "การดาวน์โหลดไฟล์ติดตั้งล้มเหลว" >&2
  exit 1
fi
sleep 10  # รอ 10 วินาที

# 2. แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน
echo "แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน:"
ls
sleep 10  # รอ 10 วินาที

# 3. เปลี่ยนสิทธิ์ของไฟล์ติดตั้งเป็น 777
chmod 777 falcon-sensor_7.16.0-16903_amd64.deb
sleep 10  # รอ 10 วินาที

# 4. แสดงรายการไฟล์ในไดเรกทอรีปัจจุบันอีกครั้ง
echo "แสดงรายการไฟล์หลังจากเปลี่ยนสิทธิ์:"
ls
sleep 10  # รอ 10 วินาที

# 5. ติดตั้งแพ็กเกจ Falcon Sensor
echo "กำลังติดตั้ง Falcon Sensor..."
dpkg -i falcon-sensor_7.16.0-16903_amd64.deb
if [ $? -ne 0 ]; then
  echo "การติดตั้งล้มเหลว หรืออาจมีปัญหาการขึ้นทะเบียนแพ็กเกจ" >&2
  echo "กำลังติดตั้ง dependencies ที่ขาดหายไป..."
  apt-get -f install -y
fi
sleep 10  # รอ 10 วินาที

# 6. ตั้งค่า CID (Customer ID) สำหรับ Falcon Sensor
echo "กำลังตั้งค่า CID..."
/opt/CrowdStrike/falconctl -s --cid=9635983EDC4A40638B282CB6965E7663-34
sleep 10  # รอ 10 วินาที
sudo /opt/CrowdStrike/falconctl -s --provisioning-token=E7BCC1A1

sleep 10  # รอ 10 วินาที
