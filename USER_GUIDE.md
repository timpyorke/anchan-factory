# Daily Jolly - Comprehensive User Guide | คู่มือการใช้งานอย่างละเอียด

This guide provides a detailed step-by-step walkthrough of the Daily Jolly application for manufacturing and quality control management.
คู่มือนี้จะอธิบายขั้นตอนการใช้งานแอปพลิเคชัน Daily Jolly อย่างละเอียด สำหรับการจัดการการผลิตและการควบคุมคุณภาพ

---

## 🇺🇸 English: Step-by-Step Guide

### Step 1: Setting up your Inventory
Before cooking, you must add your raw materials.
1.  Open the **Inventory** tab.
2.  Tap the **+** (Add) button.
3.  **Basic Details:** Enter the Name (e.g., "Sugar"), Unit (e.g., "g"), and Unit Price.
4.  **QC Initial pH:** Under the "Quality Control" section, enter the standard pH value for this material if known.
5.  **Restock Alert:** Enter a "Minimum Stock" value. If your stock falls below this number, the app will show a warning.
6.  Tap **Add** to save.

### Step 2: Creating a Professional Recipe
You can create complex recipes with parallel production lines.
1.  Open the **Recipe** tab and tap **+**.
2.  **Using Templates:** Select a **Gelling Agent Template** (e.g., Pectin). This will automatically create standard industry steps for you.
3.  **Defining Parallel Lines:** 
    *   Add or Edit a Step.
    *   In the **Production Line** field, enter "Line A" for the first line and "Line B" for the second.
    *   Steps assigned to "Line A" can be done independently of "Line B".
4.  **Setting QC Requirements:** 
    *   In each step, look for the **Quality Control** section.
    *   Toggle on what the operator **must** measure (e.g., Temperature or pH).
    *   The app will prevent the operator from finishing the step until they enter this data.
5.  **Adding Ingredients:** Select items from your inventory and specify the quantity needed for one batch.

### Step 3: Executing Manufacturing
This is where the actual production happens.
1.  Go to the **Home** tab and tap **New Manufacturing**.
2.  Select your recipe. The app will check if you have enough stock.
3.  **The Manufacturing UI:**
    *   **Single Line:** You will see cards. Follow instructions, enter notes, and tap "Next Step".
    *   **Parallel Lines:** You will see a list grouped by Line A, Line B, etc.
4.  **Logging Measurements:** If a step shows a "Required Measurement" field, enter the numeric value (e.g., 85.0 for °C). 
    *   *Note:* The "Complete" button is disabled until you enter required data.
5.  **Handling Dependencies:** If "Step 3" depends on "Step 1" and "Step 2", you cannot start Step 3 until both parallel lines are finished.
6.  **Finishing:** Once all steps are done, enter the **Total Units Produced** (e.g., if you planned 100 but produced 98, enter 90).

### Step 4: Reviewing Analytics & Consistency
1.  Tap the **Chart Icon** at the top right of the Home screen.
2.  **Compliance Score:** If this is 100%, it means your team is recording all required QC data correctly.
3.  **Variance Analysis:** Look for cards showing "±" values.
    *   *Example:* If Batch 1 pH was 3.2 and Batch 2 pH was 3.8, the app will show a variance range. High variance (in orange) means your production is inconsistent.

---

## 🇹🇭 ภาษาไทย: ขั้นตอนการใช้งานอย่างละเอียด

### ขั้นตอนที่ 1: การตั้งค่าสินค้าคงคลัง (Inventory)
ก่อนเริ่มการผลิต คุณต้องเพิ่มข้อมูลวัตถุดิบก่อน
1.  ไปที่แท็บ **สินค้าคงคลัง (Inventory)**
2.  แตะปุ่ม **+** เพื่อเพิ่มรายการใหม่
3.  **ข้อมูลพื้นฐาน:** ใส่ชื่อ (เช่น "น้ำตาล"), หน่วย (เช่น "กรัม"), และราคาต่อหน่วย
4.  **ค่า pH เริ่มต้น:** ในส่วน "ควบคุมคุณภาพ (QC)" ให้ใส่ค่า pH มาตรฐานของวัตถุดิบนั้นๆ (ถ้ามี)
5.  **การเตือนสต็อก:** ใส่ "สต็อกขั้นต่ำ" หากวัตถุดิบเหลือต่ำกว่าค่านี้ แอปจะแสดงตัวเลขเตือนสีส้ม
6.  แตะ **เพิ่ม (Add)** เพื่อบันทึก

### ขั้นตอนที่ 2: การสร้างสูตรผลิต (Recipe)
คุณสามารถสร้างสูตรที่มีขั้นตอนซับซ้อนหรือทำขนานกันได้
1.  ไปที่แท็บ **สูตร (Recipe)** แล้วแตะปุ่ม **+**
2.  **การใช้เทมเพลต:** เลือก **เทมเพลตสารก่อเจล** (เช่น เพคติน) ระบบจะสร้างขั้นตอนการผลิตมาตรฐานอุตสาหกรรมให้ทันที
3.  **การกำหนดสายการผลิตแยก (Parallel Lines):**
    *   เพิ่มหรือแก้ไขขั้นตอน (Step)
    *   ในช่อง **สายการผลิต (Production Line)** ให้ใส่ชื่อ เช่น "Line A" หรือ "Line B"
    *   ขั้นตอนที่อยู่ใน Line A จะสามารถทำไปพร้อมๆ กับ Line B ได้โดยไม่ต้องรอกัน
4.  **การกำหนดค่า QC ที่ต้องวัด:**
    *   ในแต่ละขั้นตอน ให้ดูส่วน **ควบคุมคุณภาพ (Quality Control)**
    *   เลือกเปิดหัวข้อที่พนักงาน **ต้องวัดค่า** (เช่น อุณหภูมิ หรือ pH)
    *   ระบบจะล็อคไม่ให้พนักงานกดผ่านขั้นตอนนั้น หากยังไม่ได้กรอกข้อมูลที่กำหนดไว้
5.  **การเพิ่มวัตถุดิบ:** เลือกวัตถุดิบจากคลังและระบุจำนวนที่ใช้ต่อการผลิต 1 ชุด

### ขั้นตอนที่ 3: กระบวนการผลิต (Manufacturing)
ขั้นตอนการบันทึกการทำงานจริงในโรงงาน
1.  ไปที่หน้าแรก **(Home)** แตะ **เริ่มผลิตใหม่**
2.  เลือกสูตรที่ต้องการ ระบบจะตรวจสอบว่ามีวัตถุดิบในคลังเพียงพอหรือไม่
3.  **หน้าจอการผลิต:**
    *   **สูตรทั่วไป:** จะแสดงทีละขั้นตอนแบบการ์ด ให้ทำตามและกด "ขั้นตอนถัดไป"
    *   **สูตรแบบหลายสายผลิต:** จะแสดงรายการขั้นตอนแยกกลุ่มตาม Line A, Line B ฯลฯ
4.  **การบันทึกค่าการวัด:** หากขั้นตอนนั้นมีการกำหนดค่า QC ให้กรอกตัวเลข (เช่น 85.0 สำหรับอุณหภูมิ)
    *   *หมายเหตุ:* ปุ่ม "บันทึกเสร็จสิ้น" จะกดไม่ได้จนกว่าจะกรอกข้อมูลครบ
5.  **การรอขั้นตอนที่เกี่ยวข้องกัน:** หากขั้นตอนหลักต้องการผลลัพธ์จาก Line A และ Line B คุณจะกดผ่านขั้นตอนหลักไม่ได้จนกว่าทั้งสองไลน์จะทำเสร็จสิ้น
6.  **การจบการผลิต:** เมื่อครบทุกขั้นตอน ให้ระบุ **จำนวนหน่วยที่ผลิตได้จริง** (เช่น แผนคือ 100 แต่ผลิตได้ 98 ให้กรอก 98 เพื่อบันทึกยอดจริง)

### ขั้นตอนที่ 4: การดูรายงานวิเคราะห์และความสม่ำเสมอ
1.  แตะ **ไอคอนรูปกราฟ** ที่มุมขวาบนของหน้าแรก
2.  **คะแนนความถูกต้อง (Compliance):** หากได้ 100% แสดงว่าทีมงานบันทึกค่า QC ครบถ้วนตามที่กำหนดไว้ทุกครั้ง
3.  **การวิเคราะห์ความแปรผัน (Variance):** ดูการ์ดที่แสดงค่า "±"
    *   *ตัวอย่าง:* หากแบทช์ที่ 1 วัด pH ได้ 3.2 และแบทช์ที่ 2 ได้ 3.8 แอปจะคำนวณช่วงความเบี่ยงเบน หากตัวเลขสูง (แสดงสีส้ม) หมายความว่าการผลิตของคุณยังไม่มีความสม่ำเสมอเพียงพอ
