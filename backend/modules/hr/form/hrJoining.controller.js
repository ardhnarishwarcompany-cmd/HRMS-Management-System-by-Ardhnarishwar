import { db } from "../../../config/db.js";

export const createJoining = async (req, res) => {
  try {
    const hrId = req.employee.id;

    const {
      fullName,
      fatherName,
      dob,
      gender,
      maritalStatus,
      bloodGroup,
      nationality,
      mobile,
      altMobile,
      email,
      presentAddress,
      presentCity,
      presentState,
      presentPincode,
      qualification10,
      board10,
      year10,
      percent10,
      qualification12,
      board12,
      year12,
      percent12,
      qualification_grad,
      university_grad,
      year_grad,
      percent_grad,
      qualification_pg,
      university_pg,
      year_pg,
      percent_pg,
      experienceType,
      totalExperience,
      lastCompany,
      lastDesignation,
      lastSalary,
      accountHolder,
      bankName,
      accountNumber,
      ifsc,
      branch,
      emergencyName,
      emergencyRelation,
      emergencyMobile,
      fatherOccupation,
      fatherMobile,
      motherName,
      motherOccupation,
      motherMobile,
    } = req.body;

    // The HR form uses descriptive degree field names; accept both the
    // normalized DB names and the UI aliases so older builds keep working.
    const degreeGrad = req.body.degree_grad || qualification_grad || null;
    const degreePg = req.body.degree_pg || qualification_pg || null;
    const collegeGrad = req.body.college_grad || null;
    const collegePg = req.body.college_pg || null;
    const specializationGrad = req.body.specialization_grad || null;
    const specializationPg = req.body.specialization_pg || null;
    const courseTypeGrad = req.body.courseType_grad || null;
    const courseTypePg = req.body.courseType_pg || null;
    const startYearGrad = req.body.startYear_grad || null;
    const startYearPg = req.body.startYear_pg || null;
    const passingYearGrad = req.body.passingYear_grad || year_grad || null;
    const passingYearPg = req.body.passingYear_pg || year_pg || null;

    const photo = req.files?.photo?.[0]?.filename
  ? `/uploads/profile/${req.files.photo[0].filename}`
  : req.body.photo || null;

const signature = req.files?.signature?.[0]?.filename
  ? `/uploads/signature/${req.files.signature[0].filename}`
  : req.body.signature || null;

const marksheet10 = req.files?.marksheet10?.[0]?.filename
  ? `/uploads/joining-docs/${req.files.marksheet10[0].filename}` : req.body.marksheet10 || null;
const marksheet12 = req.files?.marksheet12?.[0]?.filename
  ? `/uploads/joining-docs/${req.files.marksheet12[0].filename}` : req.body.marksheet12 || null;
const marksheetGrad = req.files?.marksheet_grad?.[0]?.filename
  ? `/uploads/joining-docs/${req.files.marksheet_grad[0].filename}` : req.body.marksheet_grad || null;
const marksheetPg = req.files?.marksheet_pg?.[0]?.filename
  ? `/uploads/joining-docs/${req.files.marksheet_pg[0].filename}` : req.body.marksheet_pg || null;

    // --- Server-side validation: reject empty/invalid submissions ---
    const clean = (v) => (typeof v === "string" ? v.trim() : v || "");
    if (!clean(fullName))
      return res.status(400).json({ message: "Full Name is required" });
    if (!clean(dob))
      return res.status(400).json({ message: "Date of Birth is required" });
    if (!clean(gender))
      return res.status(400).json({ message: "Gender is required" });
    if (!/^[6-9]\d{9}$/.test(clean(mobile)))
      return res
        .status(400)
        .json({ message: "A valid 10-digit Mobile Number is required" });
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(clean(email)))
      return res.status(400).json({ message: "A valid Email is required" });

    const safeDob = dob && dob.trim() !== "" ? dob : null;

    const sql = `
INSERT INTO joining_forms (
  hr_id, full_name, father_name, dob, gender, marital_status, blood_group, nationality,
  mobile, alt_mobile, email, present_address, present_city, present_state, present_pincode,
  qualification10, board10, year10, percent10, marksheet10,
  qualification12, board12, year12, percent12, marksheet12,
  qualification_grad, university_grad, college_grad, specialization_grad, course_type_grad,
  start_year_grad, year_grad, passing_year_grad, percent_grad, marksheet_grad,
  qualification_pg, university_pg, college_pg, specialization_pg, course_type_pg,
  start_year_pg, year_pg, passing_year_pg, percent_pg, marksheet_pg,
  experience_type, total_experience, last_company, last_designation, last_salary,
  account_holder, bank_name, account_number, ifsc, branch,
  emergency_name, emergency_relation, emergency_mobile, father_occupation, father_mobile,
  mother_name, mother_occupation, mother_mobile, photo, signature
) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
`;

    const values = [
      hrId, fullName || null, fatherName || null, safeDob, gender || null, maritalStatus || null, bloodGroup || null, nationality || null,
      mobile || null, altMobile || null, email || null, presentAddress || null, presentCity || null, presentState || null, presentPincode || null,
      qualification10 || null, board10 || null, year10 || null, percent10 || null, marksheet10,
      qualification12 || null, board12 || null, year12 || null, percent12 || null, marksheet12,
      degreeGrad, university_grad || null, collegeGrad, specializationGrad, courseTypeGrad, startYearGrad, year_grad || null, passingYearGrad, percent_grad || null, marksheetGrad,
      degreePg, university_pg || null, collegePg, specializationPg, courseTypePg, startYearPg, year_pg || null, passingYearPg, percent_pg || null, marksheetPg,
      experienceType || null, totalExperience || null, lastCompany || null, lastDesignation || null, lastSalary || null,
      accountHolder || null, bankName || null, accountNumber || null, ifsc || null, branch || null,
      emergencyName || null, emergencyRelation || null, emergencyMobile || null, fatherOccupation || null, fatherMobile || null,
      motherName || null, motherOccupation || null, motherMobile || null, photo, signature,
    ];

    await db.query(sql, values);

    res.json({
      success: true,
      message: "Joining form submitted successfully",
    });
  } catch (err) {
    console.error("Joining Error:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};
