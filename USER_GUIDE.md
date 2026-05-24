# Daily Jolly - คู่มือการใช้งานอย่างละเอียด | Comprehensive User Guide

คู่มือนี้จะอธิบายการใช้งานแอปพลิเคชัน **Daily Jolly** อย่างละเอียดทุกขั้นตอน สำหรับการจัดการการผลิต สูตรอาหาร สินค้าคงคลัง และการควบคุมคุณภาพ (QC) ในระดับโรงงาน
This guide provides a detailed walkthrough of the **Daily Jolly** app for manufacturing, recipe, inventory, and quality control management.

---

## 🇹🇭 ภาษาไทย: ขั้นตอนการใช้งานอย่างละเอียด

### ภาพรวมของแอปพลิเคชัน

Daily Jolly คือแอปสำหรับ iPad ที่ออกแบบมาเพื่อช่วยบริหารจัดการกระบวนการผลิตอาหาร ขนม หรือสินค้าสำเร็จรูปในระดับโรงงานหรือครัวเชิงพาณิชย์ มีฟีเจอร์หลัก 4 ส่วน:

- **หน้าแรก (Home)** — แสดงสรุปสถิติการผลิต สต็อกต่ำ การผลิตที่กำลังดำเนินอยู่ และประวัติการผลิตที่เสร็จแล้ว
- **สูตร (Recipe)** — สร้าง แก้ไข ทำซ้ำ และจัดการสูตรการผลิต รวมถึงการกำหนดขั้นตอน การวัดคุณภาพ และสายการผลิตแบบขนาน
- **สินค้าคงคลัง (Inventory)** — จัดการวัตถุดิบ ราคา หน่วย และการเตือนสต็อกขั้นต่ำ
- **ตั้งค่า (Settings)** — ปรับธีม ภาษา การล็อคสูตรด้วย PIN หน่วยกำหนดเอง การนำเข้า/ส่งออก CSV และการสำรองข้อมูลไปยัง Google Drive

---

### ขั้นตอนที่ 0: การตั้งค่าเริ่มต้นแอป (Initial Setup)

หลังติดตั้งแอป **Daily Jolly** ครั้งแรก แนะนำให้ทำการตั้งค่าตามลำดับนี้ก่อนเริ่มใช้งานจริง เพื่อให้แอปทำงานได้เต็มประสิทธิภาพและตรงกับกระบวนการของโรงงานคุณ

#### 0.1 เปิดแอปครั้งแรก
1. แตะไอคอน **Daily Jolly** บน iPad
2. แอปจะเปิดเข้าสู่หน้าแรก (Home) ซึ่งจะยังไม่มีข้อมูลใด ๆ
3. ไปที่แท็บ **ตั้งค่า (Settings)** ที่แถบล่างขวาสุด

#### 0.2 เลือกภาษา (Language)
> 💡 ตั้งภาษาเป็นอันดับแรก เพราะต้องรีสตาร์ทแอปเพื่อให้มีผล

1. ในหน้าตั้งค่า เลื่อนหาส่วน **Language**
2. แตะตัวเลือกภาษา แล้วเลือก:
   - 🇹🇭 **ภาษาไทย** สำหรับการใช้งานทั่วไปในประเทศไทย
   - 🇺🇸 **English** สำหรับทีมที่ใช้ภาษาอังกฤษ
3. ระบบจะแสดงป็อปอัป **"Restart Required"**
4. ปิดแอปและเปิดใหม่ — เมนูและข้อความทั้งหมดจะเปลี่ยนเป็นภาษาที่เลือก

#### 0.3 เลือกธีม (Theme)
1. ที่ส่วน **Appearance** เลือกธีมที่ต้องการ:
   - **System** — เปลี่ยนตามการตั้งค่าระบบ iPad
   - **Light** — โหมดสว่าง (เหมาะกับโรงงานที่มีแสงสว่างเพียงพอ)
   - **Dark** — โหมดมืด (ลดแสงสะท้อนในที่แสงน้อย ประหยัดแบตเตอรี่จอ OLED)
2. ระบบจะเปลี่ยนทันทีโดยไม่ต้องรีสตาร์ท

#### 0.4 เพิ่มหน่วยกำหนดเอง (Custom Units) — ถ้าจำเป็น
หากกระบวนการของคุณใช้หน่วยที่ไม่มีในระบบ (g, kg, ml, l, pcs):

1. ในส่วน **Custom Units** แตะ **Add Custom Unit**
2. กรอก:
   - **Symbol** — ตัวย่อ เช่น `cup`, `tbsp`, `cap`, `bag` (จะถูกแปลงเป็นตัวพิมพ์ใหญ่อัตโนมัติ)
   - **Name** — ชื่อเต็ม เช่น "ถ้วยตวง", "ช้อนโต๊ะ", "ฝา", "ถุง"
3. แตะ **Save**
4. ทำซ้ำกับหน่วยทั้งหมดที่ใช้ในโรงงาน

> หน่วยเหล่านี้จะปรากฏให้เลือกเมื่อสร้างวัตถุดิบใหม่ในขั้นตอนที่ 1

#### 0.5 ตั้งค่าสำรองข้อมูลไปยัง Google Drive (Cloud Backup)
> 🔒 แนะนำให้ทำตั้งแต่ครั้งแรก เพื่อป้องกันข้อมูลสูญหายหาก iPad เสียหายหรือสูญหาย

1. แตะ **Google Drive Backup** ในส่วน **Cloud Backup**
2. แตะปุ่ม **Sign in with Google**
3. เลือกบัญชี Google ที่ต้องการใช้สำรองข้อมูล (แนะนำใช้บัญชีของบริษัท ไม่ใช่ของพนักงานส่วนตัว)
4. อนุญาตการเข้าถึง Google Drive
5. หลังเชื่อมต่อสำเร็จ:
   - แตะ **Backup Now** เพื่อสำรองข้อมูลทันที
   - เปิดสวิตช์ **Auto Backup on Launch** ให้แอปสำรองอัตโนมัติทุกครั้งที่เปิดใช้
6. ไฟล์สำรองจะถูกเก็บในโฟลเดอร์ "Daily Jolly Backup" ใน Google Drive ของคุณ

> ⚠️ **ก่อนใช้:** ผู้ดูแลระบบต้องเพิ่ม `GoogleSignIn SPM` และค่า Google Cloud credentials ในแอปก่อน (ดูเอกสารสำหรับนักพัฒนา)

#### 0.6 ตั้งค่าล็อกการแก้ไขสูตรด้วย PIN (Recipe Edit Lock)
> เหมาะสำหรับโรงงานที่มีพนักงานหลายคนใช้ iPad ร่วมกัน

1. ในส่วน **Permissions** แตะ **Lock Recipe Editing**
2. ระบบจะให้กรอก **PIN 4 หลัก** สำหรับใช้ปลดล็อก
3. ยืนยัน PIN อีกครั้ง
4. เมื่อเปิดล็อก:
   - ปุ่ม **+** ในแท็บสูตรจะหายไป
   - การ swipe เพื่อ Duplicate/Delete สูตรจะถูกซ่อน
   - ไอคอน 🔒 จะปรากฏที่มุมบนซ้ายของหน้าสูตร
5. ปลดล็อกเมื่อต้องการแก้ไข: แตะ 🔒 → กรอก PIN
6. เปลี่ยน PIN ได้เมื่ออยู่ในสถานะปลดล็อก โดยแตะ **Change PIN**

> 💡 **เก็บ PIN ไว้ในที่ปลอดภัย** — ระบบไม่มีฟีเจอร์ลืม PIN หากลืม ต้องล้างข้อมูลทั้งแอป

#### 0.7 นำเข้าข้อมูลจากระบบเดิม (Import CSV) — ถ้ามี
หากมีฐานข้อมูลวัตถุดิบหรือสูตรอยู่ใน Excel/Google Sheets อยู่แล้ว:

##### นำเข้าวัตถุดิบ (Inventory)
1. เตรียมไฟล์ CSV ที่มีคอลัมน์ Header แถวแรก เช่น:
   ```
   Name,Category,Unit,UnitPrice,Stock,MinStock
   น้ำตาลทราย,สารให้ความหวาน,kg,25,50,10
   เพคติน,สารก่อเจล,g,500,2000,500
   ```
2. ส่งไฟล์ CSV ไปยัง iPad (ผ่าน AirDrop, iCloud Drive, Google Drive ฯลฯ)
3. ในหน้าตั้งค่า แตะ **Import Inventory (CSV)**
4. เลือกไฟล์ CSV
5. ระบบจะแจ้งจำนวนรายการที่นำเข้าสำเร็จและที่ข้ามไป (กรณีข้อมูลไม่ครบ)

##### นำเข้าสูตร (Recipes)
1. แตะ **Import Recipes (CSV)**
2. เลือกไฟล์ CSV
3. ตรวจสอบผลการนำเข้าใน Pop-up

> ⚠️ ตรวจสอบให้แน่ใจว่าแถวแรกของ CSV เป็น Header ที่ถูกต้อง มิฉะนั้นข้อมูลแถวแรกจะถูกตีความเป็นชื่อคอลัมน์

#### 0.8 ตรวจสอบความพร้อมก่อนเริ่มใช้งานจริง
ก่อนเริ่มสร้างวัตถุดิบและสูตร ตรวจสอบว่า:

- ✅ ภาษาตั้งถูกต้องแล้ว
- ✅ ธีมเหมาะกับสภาพแสงในโรงงาน
- ✅ หน่วยกำหนดเองทั้งหมดถูกเพิ่มแล้ว
- ✅ Google Drive Backup เชื่อมต่อสำเร็จ
- ✅ ตัดสินใจแล้วว่าจะล็อกการแก้ไขสูตรหรือไม่
- ✅ ถ้ามีข้อมูลเดิม ได้นำเข้าผ่าน CSV เรียบร้อย

#### 0.9 ลำดับการตั้งค่าที่แนะนำ (Recommended Order)
```
1. ตั้งภาษา → รีสตาร์ทแอป
2. เลือกธีม
3. เพิ่ม Custom Units (ถ้ามี)
4. เชื่อม Google Drive + เปิด Auto Backup
5. ตั้ง PIN ล็อกสูตร (ถ้าต้องการ — ทำหลังสร้างสูตรเสร็จก็ได้)
6. นำเข้า CSV (ถ้ามี) → ตรวจสอบข้อมูล
7. เริ่มขั้นตอนที่ 1: เพิ่มวัตถุดิบ
```

---

### ขั้นตอนที่ 1: การตั้งค่าสินค้าคงคลัง (Inventory)

ก่อนเริ่มสร้างสูตรหรือเริ่มการผลิต คุณต้องเพิ่มข้อมูลวัตถุดิบทั้งหมดเข้าระบบก่อน

#### 1.1 การเพิ่มวัตถุดิบใหม่
1. แตะแท็บ **สินค้าคงคลัง (Inventory)** ที่แถบล่างของหน้าจอ
2. แตะปุ่ม **+** ที่มุมบนขวา
3. ระบบจะแสดงฟอร์มเพิ่มวัตถุดิบใหม่

#### 1.2 ข้อมูลพื้นฐาน
- **ชื่อ (Name):** เช่น "น้ำตาลทราย", "เพคติน", "กรดซิตริก"
- **หมวดหมู่ (Category):** *(ไม่บังคับ)* เช่น "สารให้ความหวาน", "สารก่อเจล", "กรด"
- **หน่วย (Unit):** เลือกจากหน่วยพื้นฐาน 5 แบบ — `g` (กรัม), `kg` (กิโลกรัม), `ml` (มิลลิลิตร), `l` (ลิตร), `pcs` (ชิ้น) หรือเลือกหน่วยกำหนดเองที่สร้างไว้ในเมนูตั้งค่า
- **ราคาต่อหน่วย (Unit Price):** ราคาต่อหน่วยพื้นฐานสำหรับใช้คำนวณต้นทุนของสูตรอัตโนมัติ
- **สต็อกปัจจุบัน (Stock):** จำนวนวัตถุดิบที่มีอยู่จริงในปัจจุบัน

#### 1.3 การตั้งค่าควบคุมคุณภาพ (QC)
- **ค่า pH เริ่มต้น (Initial pH):** หากเป็นวัตถุดิบที่ต้องตรวจสอบความเป็นกรด-ด่าง ให้ใส่ค่า pH มาตรฐานของวัตถุดิบนั้น ๆ เพื่อใช้อ้างอิงระหว่างการผลิต

#### 1.4 การตั้งค่าสต็อกขั้นต่ำ (Restock Alert)
- **สต็อกขั้นต่ำ (Minimum Stock):** หากปริมาณคงเหลือต่ำกว่าค่านี้ ระบบจะแสดงคำเตือนที่หน้าแรก พร้อมแนะนำจำนวนที่ควรเติม
- เมื่อสต็อกต่ำกว่า 25% ของขั้นต่ำ → แสดงเป็นสีแดง
- ต่ำกว่า 50% → แสดงเป็นสีส้ม
- ต่ำกว่า 100% แต่สูงกว่า 50% → แสดงเป็นสีเหลือง

#### 1.5 บันทึกข้อมูล
แตะ **เพิ่ม (Add)** เพื่อบันทึก วัตถุดิบที่บันทึกแล้วจะปรากฏในรายการ Inventory และพร้อมใช้งานในสูตรทันที

---

### ขั้นตอนที่ 2: การสร้างสูตรผลิต (Recipe)

คุณสามารถสร้างสูตรตั้งแต่แบบเรียบง่ายไปจนถึงสูตรที่มีสายการผลิตหลายเส้น (Parallel Lines) และมีการกำหนดเงื่อนไขขั้นตอนที่ขึ้นต่อกัน (Dependencies)

#### 2.1 การเริ่มสร้างสูตร
1. แตะแท็บ **สูตร (Recipe)**
2. แตะปุ่ม **+** ที่มุมบนขวา
3. กรอกข้อมูลพื้นฐาน:
   - **ชื่อสูตร (Name)**
   - **หมวดหมู่ (Category)** *(ไม่บังคับ)*
   - **บันทึก (Note)** สำหรับรายละเอียดเพิ่มเติม
   - **ขนาดแบทช์ (Batch Size)** — จำนวนหน่วยที่ผลิตได้ต่อ 1 ชุดสูตร เช่น 100 ชิ้น
   - **หน่วยของแบทช์ (Batch Unit)** — เช่น "ชิ้น", "ขวด", "กล่อง"

#### 2.2 การใช้เทมเพลตสารก่อเจล (Gelling Agent Template)
ระบบมีเทมเพลตขั้นตอนมาตรฐานอุตสาหกรรมสำเร็จรูป 5 ชนิด:

| เทมเพลต | คุณสมบัติ |
|---------|-----------|
| **Pectin (เพคติน)** | ต้มที่อุณหภูมิสูง อ่อนไหวต่อค่า pH |
| **Gelatin (เจลาติน)** | ต้องแช่น้ำให้พองตัวก่อน เซ็ตที่อุณหภูมิต่ำ |
| **Agar-Agar (วุ้น)** | กระตุ้นด้วยอุณหภูมิสูง ทนความร้อนได้ดี |
| **Carrageenan (คาราจีแนน)** | เปลี่ยนเนื้อตามแรงเฉือน ละลาย/เซ็ตได้ใหม่ |
| **Starch (แป้ง)** | เกิดเจลาติไนเซชันที่อุณหภูมิเฉพาะ |

เมื่อเลือกเทมเพลตแล้ว ระบบจะสร้างขั้นตอนเริ่มต้นให้อัตโนมัติ คุณสามารถปรับแต่งภายหลังได้

#### 2.3 การเพิ่มและจัดการขั้นตอน (Steps)
ในแต่ละขั้นตอน คุณสามารถกำหนด:

- **หัวข้อ (Title):** เช่น "ผสมน้ำตาลกับเพคติน"
- **หมายเหตุ (Note):** รายละเอียดวิธีการ
- **เวลา (Time):** เวลาที่คาดว่าใช้ในขั้นตอนนี้ (เป็นนาที)
- **ต้องจับเวลา (Timer Required):** ถ้าเปิดใช้ พนักงานต้องกด "เริ่มจับเวลา" และ "บันทึกเวลา" ก่อนจะกดผ่านขั้นตอนได้
- **ลำดับ (Order):** ระบบจะจัดเรียงตามลำดับที่กำหนด
- **สายการผลิต (Production Line):** ใช้สำหรับการผลิตแบบขนาน (ดูข้อ 2.5)
- **ขั้นตอนที่ต้องเสร็จก่อน (Dependencies):** กำหนดให้ขั้นตอนนี้ต้องรอขั้นตอนอื่นเสร็จก่อน

#### 2.4 การกำหนดค่าควบคุมคุณภาพ (Quality Control) ในแต่ละขั้นตอน
ในส่วน **Quality Control** ของแต่ละขั้นตอน เปิดสวิตช์เลือกค่าที่ **บังคับ** ให้พนักงานต้องวัด มี 4 ประเภท:

- 🌡️ **Temperature (อุณหภูมิ)** — หน่วย °C
- 💧 **pH (ค่ากรด-ด่าง)** — หน่วย pH
- ⚙️ **Brix (ความหวาน)** — หน่วย °Bx
- 〰️ **Aw (ค่าน้ำอิสระ)** — หน่วย aw

> **สำคัญ:** ถ้าตั้งให้วัดค่าใด ระบบจะ **ล็อกปุ่ม "เสร็จสิ้น"** ในขั้นตอนนั้นไว้ จนกว่าพนักงานจะกรอกค่าครบ ช่วยให้ข้อมูล QC ถูกบันทึกครบทุกแบทช์โดยอัตโนมัติ

#### 2.5 การกำหนดสายการผลิตแบบขนาน (Parallel Production Lines)
เมื่อมีงานที่ทำพร้อมกันได้:

1. ในแต่ละขั้นตอน ให้กรอกชื่อสายในช่อง **Production Line** เช่น "Line A" หรือ "Line B"
2. ขั้นตอนใน Line A และ Line B จะสามารถดำเนินงานพร้อมกันได้ในหน้าจอผลิตจริง
3. หากต้องการให้ขั้นตอนสุดท้ายรอผลของทั้ง Line A และ Line B ให้กำหนด Dependencies ทั้งสองสาย

#### 2.6 การเพิ่มวัตถุดิบ (Ingredients)
1. แตะปุ่มเพิ่มวัตถุดิบ
2. เลือกจากรายการ Inventory ที่บันทึกไว้
3. ระบุปริมาณที่ใช้ต่อ **1 แบทช์** (ไม่ใช่ต่อชิ้น)
4. ระบบจะคำนวณ:
   - **ต้นทุนรวมต่อแบทช์** (จากราคาวัตถุดิบ x ปริมาณ)
   - **ต้นทุนต่อหน่วย** (ต้นทุนรวม ÷ Batch Size)

#### 2.7 บันทึกสูตร
แตะ **บันทึก (Save)** สูตรจะถูกเพิ่มในรายการสูตร พร้อมสำหรับการผลิต

#### 2.8 การจัดการสูตรในรายการ
- **ปัดซ้ายไปขวา** บนรายการสูตรเพื่อ:
  - 💗 เพิ่มเป็นรายการโปรด
  - 📄 ทำสำเนาสูตร (Duplicate) — สร้างสูตรใหม่ที่มีชื่อต่อท้าย "(Copy)" และคัดลอกทั้งวัตถุดิบและขั้นตอน
- **ปัดขวาไปซ้าย** เพื่อ:
  - 🗑️ ลบสูตร (ถ้าไม่ได้ล็อกการแก้ไขด้วย PIN)
- **แตะที่สูตร** เพื่อดูรายละเอียดและเริ่มผลิต

---

### ขั้นตอนที่ 3: กระบวนการผลิต (Manufacturing)

หัวใจของแอป คือการบันทึกการทำงานจริงในโรงงานทีละขั้นตอน พร้อมเก็บค่า QC ภาพถ่าย เวลา และบันทึกของพนักงาน

#### 3.1 เริ่มการผลิตใหม่
1. ไปที่แท็บ **หน้าแรก (Home)**
2. แตะปุ่ม **+ New Manufacturing**
3. เลือกสูตรจากรายการ
   - หากสต็อกวัตถุดิบไม่พอ ระบบจะแสดง ⚠️ **คำเตือน "Insufficient Inventory"** พร้อมรายการวัตถุดิบที่ขาด คุณเลือกได้ว่าจะยกเลิกหรือ "เริ่มต่อไป (Start Anyway)"
4. ระบบจะสร้าง **เลขแบทช์อัตโนมัติ** ในรูปแบบ `YYMMDD-XXX` เช่น `260524-001` (วันที่ 24/05/2026 แบทช์แรกของวัน)

#### 3.2 หน้าจอการผลิต
ระบบจะแสดงตามรูปแบบของสูตร:

- **สูตรทั่วไป (Linear):** แสดงทีละขั้นตอนแบบการ์ด พร้อมแถบความคืบหน้า
- **สูตรหลายสาย (Parallel Lines):** แสดงรายการขั้นตอนแยกกลุ่มตาม "Line A", "Line B" ฯลฯ พนักงานสามารถเลือกทำขั้นตอนใดของสายไหนก่อนก็ได้ ตราบใดที่ Dependencies ครบ

#### 3.3 การทำงานในแต่ละขั้นตอน

**(ก) อ่านคำสั่ง:** ดูหัวข้อและบันทึกของขั้นตอน

**(ข) จับเวลา (ถ้ากำหนดไว้):**
- แตะ **เริ่มจับเวลา (Start Timer)** เพื่อเริ่ม
- ระบบจะแสดงเวลาแบบนาฬิกาจับเวลา (Stopwatch)
- เมื่อทำเสร็จ แตะ **บันทึกเวลา (Record Time)**
- หากบันทึกผิด สามารถแตะ **บันทึกใหม่ (Re-record)** ได้

**(ค) ถ่ายภาพ (Optional):**
- แตะปุ่มกล้องเพื่อถ่ายภาพประกอบขั้นตอน
- สามารถเพิ่มภาพได้จากกล้องสด หรือเลือกจากคลังภาพ
- ภาพจะถูกผูกกับขั้นตอนนั้น ๆ และดูได้ในประวัติแบทช์

**(ง) บันทึกค่าควบคุมคุณภาพ (QC):**
หากขั้นตอนกำหนดให้วัดค่า (จากข้อ 2.4) จะเห็นช่องกรอกค่า เช่น:
- "อุณหภูมิ: ___ °C"
- "pH: ___"
- "Brix: ___ °Bx"
- "Aw: ___"

ปุ่ม **เสร็จสิ้น (Complete)** จะกดไม่ได้จนกว่าค่า QC ที่บังคับจะถูกกรอกครบ และ (ถ้ามี) เวลาจับถูกบันทึก

**(จ) บันทึกหมายเหตุ (Optional):**
ช่อง "Note" ในแต่ละขั้นตอน ใช้บันทึกสิ่งที่เกิดขึ้นจริง เช่น "อุณหภูมิเตาขึ้นช้ากว่าปกติ"

**(ฉ) กดถัดไป:**
- แตะ **ขั้นตอนถัดไป (Next Step)** หรือ **เสร็จสิ้น (Complete)**

#### 3.4 การจัดการขั้นตอนที่ขึ้นต่อกัน (Dependencies)
หากขั้นตอนที่ 5 ถูกตั้งให้ต้องรอ "ขั้นตอน 3 (Line A)" และ "ขั้นตอน 4 (Line B)" เสร็จก่อน:
- ระบบจะ **ล็อก** ขั้นตอน 5 ไม่ให้กดได้ จนกว่าทั้ง 2 ขั้นตอนจะถูกทำเครื่องหมายว่าเสร็จแล้ว
- ในมุมมอง Parallel Lines พนักงานสามารถสลับกันทำขั้นตอน 3 และ 4 ได้อิสระ

#### 3.5 การปิดการผลิต (Completion)
เมื่อทำครบทุกขั้นตอน:
1. ระบบจะพาไปหน้า **สรุปการผลิต**
2. ระบุ **จำนวนหน่วยที่ผลิตได้จริง (Total Units Produced)** — เช่น แผนคือ 100 ชิ้น แต่ผลิตจริงได้ 97 ชิ้น (อาจมีสูญเสีย) ให้กรอก 97
3. เพิ่ม **ภาพถ่ายงานสำเร็จ** (Final Photos) เพื่อบันทึกผลผลิต
4. แตะ **Complete Manufacturing** เพื่อบันทึกแบทช์เข้าระบบ
5. ระบบจะ **หักสต็อกวัตถุดิบ** ตามที่ใช้จริงโดยอัตโนมัติ (อ้างอิงตามสูตร x จำนวนแบทช์)

---

### ขั้นตอนที่ 4: การดูรายงานวิเคราะห์ (Analytics & QC)

#### 4.1 การเข้าถึงรายงาน
แตะ **ไอคอนกราฟ** 📊 ที่มุมบนขวาของหน้าแรก หรือปุ่ม **"View Detailed Quality Control Analytics"**

#### 4.2 คะแนนความถูกต้อง (Compliance Score)
แสดงเป็นวงกลมเปอร์เซ็นต์:
- 🟢 **90% ขึ้นไป** — ทีมงานบันทึก QC ครบถ้วนเป็นประจำ
- 🟠 **70-89%** — ขาดการบันทึกบางครั้ง
- 🔴 **ต่ำกว่า 70%** — ต้องอบรมพนักงานหรือปรับปรุงระบบ

คะแนนคำนวณจาก: *(จำนวนค่า QC ที่บันทึกจริง) ÷ (จำนวนค่า QC ที่ควรบันทึก)* x 100%

#### 4.3 การวิเคราะห์ความแปรผัน (Variance Analysis)
เปรียบเทียบค่า QC ระหว่างแบทช์ของสูตรเดียวกัน:

- **Average (เฉลี่ย):** ค่าเฉลี่ยทุกแบทช์
- **Min/Max:** ค่าต่ำสุดและสูงสุด
- **Variance Range (± ค่า):** ช่วงความเบี่ยงเบนจากค่าเฉลี่ย

ตัวอย่าง: หากสูตร "เยลลี่เพคติน" วัด pH ได้ 3.2, 3.5, 3.8 ในแต่ละแบทช์ → Variance Range = ±0.3 pH

**เกณฑ์เตือน (สีส้ม = แปรผันสูง):**
- pH: > 0.5
- Brix: > 2.0 °Bx
- Temperature: > 5.0 °C
- Aw: > 0.05

> ต้องมีอย่างน้อย **2 แบทช์** ของสูตรเดียวกันที่บันทึกค่า QC จึงจะเห็นข้อมูล Variance

---

### ขั้นตอนที่ 5: การตั้งค่า (Settings)

#### 5.1 รูปลักษณ์ (Appearance)
เลือกธีม: **อัตโนมัติตามระบบ / สว่าง / มืด**

#### 5.2 ภาษา (Language)
สลับระหว่าง **ภาษาไทย 🇹🇭** และ **English 🇺🇸**
> หลังเปลี่ยนภาษา ระบบจะแจ้งให้รีสตาร์ทแอปเพื่อให้มีผล

#### 5.3 สิทธิ์การเข้าถึง (Permissions) — ล็อกการแก้ไขสูตร
ป้องกันไม่ให้พนักงานแก้ไขสูตรโดยไม่ตั้งใจ:
1. แตะ **Lock Recipe Editing**
2. หากตั้ง PIN ครั้งแรก ระบบจะให้กรอก PIN 4 หลัก
3. เมื่อล็อกแล้ว ปุ่มเพิ่ม/แก้ไข/ลบ/ทำสำเนาสูตรจะหายไป
4. ปลดล็อกได้โดยแตะไอคอน 🔒 ที่หน้าสูตร แล้วกรอก PIN
5. เปลี่ยน PIN ได้เมื่ออยู่ในสถานะ "ปลดล็อก"

#### 5.4 หน่วยกำหนดเอง (Custom Units)
เพิ่มหน่วยที่ไม่มีในระบบ เช่น "ถ้วย (cup)", "ช้อนโต๊ะ (tbsp)", "ฝา (cap)"
- หน่วยที่สร้างจะแสดงเป็นตัวพิมพ์ใหญ่ในระบบ
- ใช้ได้ทันทีเมื่อสร้างวัตถุดิบใหม่

#### 5.5 นำเข้าข้อมูล (Import CSV)
- **Import Inventory** — นำเข้าวัตถุดิบจากไฟล์ CSV (แถวแรกต้องเป็น Header เช่น `Name, Category, Unit, UnitPrice, Stock, MinStock`)
- **Import Recipes** — นำเข้าสูตรจาก CSV
- ระบบจะแจ้งจำนวนรายการที่นำเข้าสำเร็จและที่ข้ามไป

#### 5.6 ส่งออกข้อมูล (Export CSV)
ส่งออกเป็นไฟล์ `.csv` เพื่อนำไปใช้กับ Google Sheets หรือ Excel:
- **Manufacturing Data** — ประวัติการผลิตทั้งหมด พร้อมค่า QC
- **Inventory Data** — รายการวัตถุดิบ
- **Recipe Data** — สูตรทั้งหมด

#### 5.7 สำรองข้อมูลขึ้นคลาวด์ (Google Drive Backup)
- เชื่อมต่อบัญชี Google เพื่อสำรองข้อมูลทั้งหมดไปยัง Google Drive
- เปิด **Auto Backup on Launch** เพื่อให้สำรองอัตโนมัติทุกครั้งที่เปิดแอป
- สามารถ Restore ข้อมูลกลับมาได้

#### 5.8 ลบข้อมูลทั้งหมด (Clear All Data)
- ⚠️ **ระวัง:** การลบนี้จะลบสูตร วัตถุดิบ และประวัติการผลิต **ทั้งหมด** อย่างถาวร
- ใช้เฉพาะเมื่อต้องการเริ่มต้นใหม่หรือทดสอบระบบ

---

### เคล็ดลับการใช้งาน (Tips & Best Practices)

1. **เริ่มจาก Inventory ก่อนเสมอ** — ใส่ราคาวัตถุดิบให้ครบ ระบบจะคำนวณต้นทุนสูตรให้อัตโนมัติ
2. **กำหนด Min Stock ทุกตัว** — เพื่อให้แอปเตือนเมื่อใกล้หมด
3. **ใช้ Production Lines** — สำหรับสูตรซับซ้อนที่ทำขนานกันได้ ช่วยลดเวลา
4. **บังคับ QC ในขั้นตอนวิกฤต** — เช่น ขั้นตอน "ตรวจ pH หลังต้ม" ของสูตรเพคติน
5. **ดู Analytics ทุกสัปดาห์** — ใช้ Variance ตรวจหาความไม่สม่ำเสมอของการผลิต
6. **เปิด Auto Backup** — ป้องกันข้อมูลหายหาก iPad เสียหาย
7. **ล็อกการแก้ไขสูตรด้วย PIN** — เมื่อหลายคนใช้ iPad ร่วมกัน เพื่อป้องกันความผิดพลาด
8. **ส่งออก CSV เป็นประจำ** — เก็บเป็นบันทึกถาวรนอกระบบ

---

## 🇺🇸 English: Detailed Step-by-Step Guide

### App Overview

Daily Jolly is an iPad app designed for managing food, dessert, or finished-goods production at the factory or commercial-kitchen scale. The four core areas are:

- **Home** — Summary stats, low-stock alerts, in-progress runs, and recent batches.
- **Recipe** — Create, edit, duplicate, and manage production recipes, including steps, QC requirements, and parallel production lines.
- **Inventory** — Manage raw materials with prices, units, and minimum-stock thresholds.
- **Settings** — Theme, language, PIN-lock for recipe editing, custom units, CSV import/export, and Google Drive backup.

---

### Step 0: Initial App Setup

After installing **Daily Jolly** for the first time, configure the app in this order before real use, so it matches your factory's workflow and runs at full capability.

#### 0.1 First Launch
1. Tap the **Daily Jolly** icon on iPad.
2. The Home screen opens — empty by design.
3. Go to the **Settings** tab (bottom-right).

#### 0.2 Choose Language
> 💡 Set the language first, since it requires an app restart to apply.

1. In Settings, find the **Language** section.
2. Tap the picker and choose:
   - 🇹🇭 **ภาษาไทย** — for Thai-speaking teams
   - 🇺🇸 **English** — for English-speaking teams
3. A **"Restart Required"** alert appears.
4. Close and reopen the app — all menus and labels switch to the chosen language.

#### 0.3 Choose Theme
1. In **Appearance**, pick:
   - **System** — follows the iPad's system setting
   - **Light** — bright mode (good for well-lit factories)
   - **Dark** — dark mode (less glare in low light; saves battery on OLED screens)
2. Changes apply immediately, no restart needed.

#### 0.4 Add Custom Units — if needed
If your process uses units outside the built-ins (g, kg, ml, l, pcs):

1. In **Custom Units**, tap **Add Custom Unit**.
2. Fill in:
   - **Symbol** — short code like `cup`, `tbsp`, `cap`, `bag` (auto-uppercased)
   - **Name** — full name like "Cup", "Tablespoon", "Cap", "Bag"
3. Tap **Save**.
4. Repeat for every custom unit your factory uses.

> These will appear as options when creating inventory items in Step 1.

#### 0.5 Set Up Google Drive Backup (Cloud Backup)
> 🔒 Recommended on day one to protect against iPad loss or damage.

1. Tap **Google Drive Backup** under **Cloud Backup**.
2. Tap **Sign in with Google**.
3. Choose the Google account to use (prefer a company account, not a personal one).
4. Grant Google Drive access.
5. After connecting:
   - Tap **Backup Now** for an immediate backup.
   - Enable **Auto Backup on Launch** so the app backs up every time it opens.
6. Backup files are stored in the "Daily Jolly Backup" folder in your Google Drive.

> ⚠️ **Prerequisite:** an admin must add the `GoogleSignIn SPM` package and Google Cloud credentials to the build first (see developer docs).

#### 0.6 Set Up PIN Lock for Recipe Editing
> Best for factories where multiple operators share one iPad.

1. In **Permissions**, tap **Lock Recipe Editing**.
2. Set a **4-digit PIN** for unlocking.
3. Confirm the PIN.
4. Once locked:
   - The **+** button on the Recipe tab disappears.
   - Swipe-to-duplicate / delete on recipes is hidden.
   - A 🔒 icon appears in the top-left of the Recipe screen.
5. Unlock when needed: tap 🔒 → enter PIN.
6. Change the PIN while unlocked by tapping **Change PIN**.

> 💡 **Store the PIN somewhere safe** — there is no "forgot PIN" recovery. Lost PIN = clear all data to reset.

#### 0.7 Import Existing Data (CSV) — if any
If you already have inventory or recipes in Excel / Google Sheets:

##### Import Inventory
1. Prepare a CSV with header row, e.g.:
   ```
   Name,Category,Unit,UnitPrice,Stock,MinStock
   Sugar,Sweetener,kg,25,50,10
   Pectin,Gelling Agent,g,500,2000,500
   ```
2. Transfer the CSV to the iPad (AirDrop, iCloud Drive, Google Drive, etc.).
3. In Settings, tap **Import Inventory (CSV)**.
4. Pick the file.
5. The app reports rows imported and rows skipped (for incomplete data).

##### Import Recipes
1. Tap **Import Recipes (CSV)**.
2. Pick the file.
3. Check the result pop-up.

> ⚠️ Make sure row 1 is a valid header — otherwise the first row of data will be misread as column names.

#### 0.8 Pre-Flight Check
Before creating materials and recipes, confirm:

- ✅ Language is correct
- ✅ Theme suits the factory lighting
- ✅ All custom units are added
- ✅ Google Drive Backup connected successfully
- ✅ PIN-lock policy decided
- ✅ Existing data imported via CSV (if applicable)

#### 0.9 Recommended Setup Order
```
1. Set language → restart app
2. Choose theme
3. Add Custom Units (if any)
4. Connect Google Drive + enable Auto Backup
5. Set PIN lock (optional — can also be done after recipes exist)
6. Import CSV (if any) → verify data
7. Proceed to Step 1: add inventory items
```

---

### Step 1: Setting Up Your Inventory

Before creating recipes or starting production, add all your raw materials.

#### 1.1 Adding a New Material
1. Tap the **Inventory** tab at the bottom.
2. Tap the **+** button in the top-right.
3. The new-material form appears.

#### 1.2 Basic Details
- **Name:** e.g., "Sugar", "Pectin", "Citric Acid".
- **Category:** *(optional)* e.g., "Sweetener", "Gelling Agent", "Acid".
- **Unit:** Choose from 5 built-in units — `g`, `kg`, `ml`, `l`, `pcs` — or any custom unit you've created in Settings.
- **Unit Price:** Price per base unit. Used to auto-calculate recipe cost.
- **Stock:** Current quantity on hand.

#### 1.3 Quality Control Setup
- **Initial pH:** For materials that require acid-base monitoring, enter the standard pH for reference during production.

#### 1.4 Restock Alert
- **Minimum Stock:** If stock falls below this value, the app warns you on the Home screen with a restock suggestion.
- Below 25% → red indicator
- Below 50% → orange indicator
- Above 50% → yellow indicator

#### 1.5 Save
Tap **Add**. The material now appears in your Inventory and is available for use in recipes.

---

### Step 2: Creating a Professional Recipe

You can build everything from simple recipes to complex ones with parallel production lines and step dependencies.

#### 2.1 Start a New Recipe
1. Tap the **Recipe** tab.
2. Tap **+** in the top-right.
3. Fill in the basics:
   - **Name**
   - **Category** *(optional)*
   - **Note** for extra details
   - **Batch Size** — how many units one full recipe produces (e.g., 100)
   - **Batch Unit** — e.g., "pcs", "bottles", "boxes"

#### 2.2 Using Gelling Agent Templates
Five industry-standard templates are built in:

| Template | Properties |
|----------|------------|
| **Pectin** | High-temperature cooking, pH sensitive |
| **Gelatin** | Hydration required, low-temperature set |
| **Agar-Agar** | High-temperature activation, heat stable |
| **Carrageenan** | Shear thinning, thermoreversible |
| **Starch** | Gelatinization at a specific temperature |

Selecting a template auto-generates the standard steps; you can edit them afterwards.

#### 2.3 Adding and Managing Steps
For each step, configure:

- **Title:** e.g., "Mix sugar with pectin"
- **Note:** Detailed instructions
- **Time:** Estimated minutes
- **Timer Required:** When enabled, the operator must tap "Start Timer" and "Record Time" before completing the step.
- **Order:** Steps are sorted by this value.
- **Production Line:** Used for parallel production (see 2.5).
- **Dependencies:** Force this step to wait until certain other steps finish.

#### 2.4 Setting QC Requirements per Step
In each step's **Quality Control** section, toggle on the values the operator **must** record. Four measurement types:

- 🌡️ **Temperature** — °C
- 💧 **pH**
- ⚙️ **Brix** — °Bx
- 〰️ **Aw** — water activity

> **Important:** When a measurement is required, the **"Complete"** button is locked until the operator enters the value. This guarantees QC data is captured every batch.

#### 2.5 Parallel Production Lines
For work that can happen simultaneously:

1. In each step, fill the **Production Line** field with a name like "Line A" or "Line B".
2. Steps in Line A and Line B can run in parallel during manufacturing.
3. To force the final step to wait for both lines, add both as Dependencies.

#### 2.6 Adding Ingredients
1. Tap "Add Ingredient".
2. Pick from the saved Inventory list.
3. Enter the quantity used per **batch** (not per unit).
4. The app automatically computes:
   - **Total cost per batch** (material price × quantity)
   - **Cost per unit** (total cost ÷ batch size)

#### 2.7 Save the Recipe
Tap **Save**. The recipe is added and ready to use.

#### 2.8 Managing Recipes in the List
- **Swipe right-to-left** on a recipe to:
  - 💗 Toggle favorite
  - 📄 Duplicate — creates a new recipe with name suffix "(Copy)" and all steps + ingredients cloned
- **Swipe left-to-right** to:
  - 🗑️ Delete (if recipe editing is not PIN-locked)
- **Tap** to view details and start production.

---

### Step 3: Executing Manufacturing

The heart of the app — recording real production step by step with QC values, photos, timing, and operator notes.

#### 3.1 Start a New Production Run
1. Go to the **Home** tab.
2. Tap **+ New Manufacturing**.
3. Pick a recipe.
   - If stock is insufficient, an ⚠️ **"Insufficient Inventory"** alert lists the missing items. You can cancel or **"Start Anyway"**.
4. The system auto-generates a **batch number** in `YYMMDD-XXX` format, e.g., `260524-001` (first batch on May 24, 2026).

#### 3.2 Manufacturing Screen
Layout depends on the recipe structure:

- **Linear recipes:** Cards shown one step at a time, with a progress bar.
- **Parallel-line recipes:** Steps grouped by "Line A", "Line B", etc. — operators can tackle any step in any line, as long as Dependencies are met.

#### 3.3 Working Through a Step

**(a) Read instructions:** Title and notes.

**(b) Run timer (if required):**
- Tap **Start Timer**.
- A live stopwatch appears.
- When finished, tap **Record Time**.
- If recorded by mistake, tap **Re-record**.

**(c) Take photos (optional):**
- Tap the camera button to attach photos.
- Capture from camera or pick from library.
- Photos are linked to that step and viewable in batch history.

**(d) Log QC measurements:**
If the step requires measurements (from 2.4), input fields appear, e.g.:
- "Temperature: ___ °C"
- "pH: ___"
- "Brix: ___ °Bx"
- "Aw: ___"

The **Complete** button stays disabled until required QC values and (if applicable) a recorded time are entered.

**(e) Add a note (optional):**
Use the "Note" field to log what actually happened, e.g., "stove ramped up slower than usual".

**(f) Move on:**
Tap **Next Step** or **Complete**.

#### 3.4 Handling Dependencies
If Step 5 requires Steps 3 (Line A) and 4 (Line B) to be done first:
- Step 5 stays **locked** until both are marked complete.
- In Parallel-Line view, operators can freely choose the order of Steps 3 and 4.

#### 3.5 Finishing the Run
Once all steps are done:
1. The app navigates to a **completion summary**.
2. Enter the **Total Units Produced** — e.g., planned 100, actually got 97 (with some loss), enter 97.
3. Add **Final Photos** of the finished product.
4. Tap **Complete Manufacturing**.
5. The app **deducts material stock** automatically based on the recipe × batch count.

---

### Step 4: Reviewing Analytics & QC

#### 4.1 Open the Dashboard
Tap the **chart icon** 📊 in the top-right of Home, or the **"View Detailed Quality Control Analytics"** button.

#### 4.2 Compliance Score
Shown as a circular percentage:
- 🟢 **90%+** — team consistently records QC
- 🟠 **70–89%** — occasional misses
- 🔴 **< 70%** — operator training or process review needed

Formula: *(QC values actually recorded) ÷ (QC values required)* × 100%.

#### 4.3 Variance Analysis
Compares QC values across batches of the same recipe:

- **Average:** mean across all batches
- **Min / Max:** lowest and highest readings
- **Variance Range (±):** deviation from the mean

Example: A "Pectin Jelly" recipe with pH readings 3.2, 3.5, 3.8 → Variance Range = ±0.3 pH.

**Warning thresholds (orange = high variance):**
- pH > 0.5
- Brix > 2.0 °Bx
- Temperature > 5.0 °C
- Aw > 0.05

> You need at least **two batches** of the same recipe with QC logged to see variance data.

---

### Step 5: Settings

#### 5.1 Appearance
Choose theme: **System / Light / Dark**.

#### 5.2 Language
Switch between **🇹🇭 ไทย** and **🇺🇸 English**.
> Restart the app after changing language.

#### 5.3 Permissions — Recipe Edit Lock
Prevents accidental recipe changes by operators:
1. Tap **Lock Recipe Editing**.
2. First-time setup prompts you to set a 4-digit PIN.
3. Once locked, add/edit/delete/duplicate controls disappear.
4. Unlock by tapping 🔒 on the Recipe screen and entering the PIN.
5. Change PIN while in "Unlocked" state.

#### 5.4 Custom Units
Add units beyond the built-ins, e.g., "cup", "tbsp", "cap".
- Symbols display in uppercase.
- Available immediately when creating new inventory items.

#### 5.5 Import CSV
- **Import Inventory** — bring in materials from a CSV (first row must be headers: `Name, Category, Unit, UnitPrice, Stock, MinStock`).
- **Import Recipes** — bring in recipes from a CSV.
- The app reports how many rows imported and how many were skipped.

#### 5.6 Export CSV
Export `.csv` files for Google Sheets or Excel:
- **Manufacturing Data** — full production history with QC values
- **Inventory Data** — all materials
- **Recipe Data** — all recipes

#### 5.7 Google Drive Backup
- Sign in to Google to back up all data to your Google Drive.
- Enable **Auto Backup on Launch** to back up automatically on app open.
- Restore from a previous backup at any time.

#### 5.8 Clear All Data
- ⚠️ **Warning:** Permanently deletes **all** recipes, inventory, and manufacturing history.
- Use only for a fresh start or testing.

---

### Tips & Best Practices

1. **Start with Inventory** — fill in unit prices so recipes auto-cost themselves.
2. **Set Min Stock on every item** — let the app warn you before you run out.
3. **Use Production Lines** — for complex recipes that can be parallelized to save time.
4. **Require QC on critical steps** — e.g., "Check pH after boiling" for pectin recipes.
5. **Review Analytics weekly** — use variance to spot inconsistency in production.
6. **Enable Auto Backup** — protect your data if the iPad fails.
7. **PIN-lock recipe editing** — when multiple operators share one iPad.
8. **Export CSV regularly** — keep external records as a safety net.
