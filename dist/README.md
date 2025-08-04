# Car Route App APK

## 📦 APK & Demo Links

| Resource          | Link                                                                                          | Notes                                                                                       |
|-------------------|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| **Debug APK**      | [Download APK](https://drive.google.com/file/d/1d9IwOXQBips0SXoFCf1gv0KfFSLSzEa2/view?usp=sharing) | Hosted externally due to GitHub file size limitations (max ~100 MB per file). Debug build ensures seamless integration with Google Maps and Directions API. |
| **Video Demo – Light Mode** | [Watch Demo](https://drive.google.com/file/d/1bSWtpSvNP8fyWllK8rPC3D_fDDuIrYKR/view)             | Demonstrates app functionality in **Light Mode**, including origin/destination selection and live route visualization. |
| **Video Demo – Night Mode** | [Watch Demo](https://drive.google.com/file/d/1bL-LmROWq7_BC-2gXhC_hGOKZfKY1onV/view)             | Showcases app functionality in **Night Mode**, with dynamic map styling and route rendering. |



## 📦 APK & Submission Notes

### 🔹 Debug APK Provided
- This submission includes a **Debug APK** instead of a Release APK.  
- **Reason:**  
  1. **Google Maps API Key** is securely stored in `local.properties` for development.  
  2. **Directions API** is integrated via **Android environment variables**, which may not work in a signed Release build without additional setup.  
  3. **Debug builds** ensure the Directions API works seamlessly during testing.  
  4. **Debug APK size** is larger than release builds because of additional debug symbols.  

---

### 🔹 Third-Party Directions API
- **API Used:** `https://maps.gomaps.pro/maps/api/directions/json`  
- **Why Used:**  
  1. Official **Google Directions API** is **paid** and requires billing.  
  2. This free, third-party API allows **testing without billing** while maintaining compatibility with standard Google Maps route data.  

---

> **Note:** Debug APK is provided to ensure all map and directions features work **out-of-the-box** for evaluation.
