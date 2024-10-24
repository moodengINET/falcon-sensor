#!/bin/bash

# ตรวจสอบให้แน่ใจว่าสคริปต์รันด้วยสิทธิ์ของผู้ใช้ root
if [ "$(id -u)" -ne 0 ]; then
  echo "สคริปต์นี้ต้องรันด้วยสิทธิ์ root" >&2
  exit 1
fi

# ตรวจสอบระบบปฏิบัติการจากไฟล์ /etc/os-release
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID        # ระบบปฏิบัติการ (ubuntu, centos, almalinux, etc.)
  OS_VERSION=$VERSION_ID  # เวอร์ชันของ OS
elif [ -f /etc/centos-release ]; then
  OS_ID="centos"
  OS_VERSION=$(rpm -q --queryformat '%{VERSION}' centos-release)
else
  echo "ไม่สามารถตรวจสอบระบบปฏิบัติการได้" >&2
  exit 1
fi

echo "ตรวจพบระบบปฏิบัติการ: $OS_ID $OS_VERSION"

# เงื่อนไขสำหรับ Ubuntu
if [[ "$OS_ID" == "ubuntu" ]]; then
  echo "ระบบปฏิบัติการเป็น Ubuntu"

  # 1. ดาวน์โหลดไฟล์ติดตั้ง Falcon Sensor จากลิงก์ที่กำหนด
  echo "กำลังดาวน์โหลด Falcon Sensor สำหรับ Ubuntu..."
 curl -k -o falcon-sensor_7.17.0-17005_amd64.deb https://203.150.48.120/owncloud/index.php/s/zOHuOuSa3EdsOxb
  if [ $? -ne 0 ]; then
    echo "การดาวน์โหลดไฟล์ติดตั้งล้มเหลว" >&2
    exit 1
  fi

  # แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน
  echo "แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน:"
  ls

  # เปลี่ยนสิทธิ์ของไฟล์ติดตั้งเป็น 777
  chmod 777 falcon-sensor_7.16.0-16903_amd64.deb

  # แสดงรายการไฟล์อีกครั้งหลังเปลี่ยนสิทธิ์
  echo "แสดงรายการไฟล์หลังจากเปลี่ยนสิทธิ์:"
  ls

  # ติดตั้งแพ็กเกจ Falcon Sensor
  echo "กำลังติดตั้ง Falcon Sensor..."
  dpkg -i falcon-sensor_7.16.0-16903_amd64.deb
  if [ $? -ne 0 ]; then
    echo "การติดตั้งล้มเหลว" >&2
    exit 1
  fi

# เงื่อนไขสำหรับ CentOS และ RedHat
elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" ]]; then
  echo "ระบบปฏิบัติการเป็น CentOS/RedHat"

  # ตรวจสอบเวอร์ชัน CentOS เพื่อเลือกไฟล์ที่ถูกต้อง
  if [[ "$OS_VERSION" == "6" ]]; then
    FALCON_SENSOR_URL="falcon-sensor-7.17.0-17005.el6.x86_64.rpm https://203.150.48.120/owncloud/index.php/s/uRaOh0AefYWRgNt"
  elif [[ "$OS_VERSION" == "7" ]]; then
    FALCON_SENSOR_URL="falcon-sensor-7.18.0-17129.el7.x86_64.rpm https://203.150.48.120/owncloud/index.php/s/ydQU8Hjt2OGlY0r"
  elif [[ "$OS_VERSION" == "8" ]]; then
    FALCON_SENSOR_URL="falcon-sensor-7.18.0-17129.el8.x86_64.rpm https://203.150.48.120/owncloud/index.php/s/vRKJDTHh1tPksZh"
  elif [[ "$OS_VERSION" == "9" ]]; then
    FALCON_SENSOR_URL="falcon-sensor-7.15.0-16803.el9.x86_64.rpm https://203.150.48.120/owncloud/index.php/s/olhwarRd7MDyPLs"
  else
    echo "ระบบปฏิบัติการนี้ไม่ได้รับการรองรับ" >&2
    exit 1
  fi

  # ดาวน์โหลดไฟล์ติดตั้ง Falcon Sensor ตามเวอร์ชันของ CentOS
  echo "กำลังดาวน์โหลด Falcon Sensor สำหรับ CentOS $OS_VERSION..."
 curl -k -o $FALCON_SENSOR_URL
  if [ $? -ne 0 ]; then
    echo "การดาวน์โหลดไฟล์ติดตั้งล้มเหลว" >&2
    exit 1
  fi

  # แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน
  echo "แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน:"
  ls

  # เปลี่ยนสิทธิ์ของไฟล์ติดตั้งเป็น 777
  chmod 777 falcon-sensor*.rpm

  # แสดงรายการไฟล์อีกครั้งหลังเปลี่ยนสิทธิ์
  echo "แสดงรายการไฟล์หลังจากเปลี่ยนสิทธิ์:"
  ls

  # ติดตั้งแพ็กเกจ Falcon Sensor
  echo "กำลังติดตั้ง Falcon Sensor..."
  yum localinstall -y falcon-sensor*.rpm
  if [ $? -ne 0 ]; then
    echo "การติดตั้งล้มเหลว" >&2
    exit 1
  fi

# เงื่อนไขสำหรับ AlmaLinux
elif [[ "$OS_ID" == "almalinux" ]]; then
  echo "ระบบปฏิบัติการเป็น AlmaLinux"

  # ดาวน์โหลดไฟล์ติดตั้ง Falcon Sensor สำหรับ AlmaLinux
  echo "กำลังดาวน์โหลด Falcon Sensor สำหรับ AlmaLinux..."
 curl -k -o falcon-sensor-7.06.0-16108.el9.x86_64.rpm https://203.150.48.120/owncloud/index.php/s/FQhU7UeVKE9OlWn
  if [ $? -ne 0 ]; then
    echo "การดาวน์โหลดไฟล์ติดตั้งล้มเหลว" >&2
    exit 1
  fi

  # แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน
  echo "แสดงรายการไฟล์ในไดเรกทอรีปัจจุบัน:"
  ls

  # เปลี่ยนสิทธิ์ของไฟล์ติดตั้งเป็น 777
  chmod 777 falcon-sensor*.rpm

  # แสดงรายการไฟล์อีกครั้งหลังเปลี่ยนสิทธิ์
  echo "แสดงรายการไฟล์หลังจากเปลี่ยนสิทธิ์:"
  ls

  # ติดตั้งแพ็กเกจ Falcon Sensor
  echo "กำลังติดตั้ง Falcon Sensor..."
  yum localinstall -y falcon-sensor*.rpm
  if [ $? -ne 0 ]; then
    echo "การติดตั้งล้มเหลว" >&2
    exit 1
  fi

else
  echo "ระบบปฏิบัติการนี้ไม่ได้รับการรองรับ"
  exit 1
fi

# 6. ตั้งค่า CID (Customer ID) สำหรับ Falcon Sensor
echo "กำลังตั้งค่า CID..."
/opt/CrowdStrike/falconctl -s --cid=9635983EDC4A40638B282CB6965E7663-34
sudo /opt/CrowdStrike/falconctl -s --provisioning-token=E7BCC1A1
sleep 3  # รอ 3 วินาที
systemctl enable falcon-sensor
systemctl restart falcon-sensor
systemctl status falcon-sensor
sleep 3  # รอ 3 วินาที
