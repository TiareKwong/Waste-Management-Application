# Waste Management Application

## Overview
The **Waste Management App** is a community-driven platform for improving waste management practices. The app allows users to report waste-related issues by submitting reports with location details, descriptions, and images, helping local authorities and communities manage waste disposal more efficiently. Additionally, users can view and receive real-time notifications about waste collection schedules in their area, ensuring they never miss a pickup.

This app utilizes **Flutter** for the frontend, **Node.js** for the backend, and **MySQL** as the database, hosted on **DigitalOcean**.

## Features
- **Real-time Location Tracking**: Automatically fetches the user’s current location using GPS and integrates Google Maps.
- **Multimedia Issue Reporting**: Users can report waste management issues with a detailed description, image, and location.
- **Location Map Integration**: Users can use their current location or select a specific location on a map to report issues.
- **Image Picker**: Users can take photos using the camera or upload images from the gallery to include in the report.
- **Collection Schedule Notifications**: Users can view scheduled waste collection dates and receive notifications for upcoming pickups in their area, ensuring they are informed ahead of time.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js, Express.js
- **Database**: MySQL (Hosted on DigitalOcean)
- **APIs**: Google Maps API, Location API, ImagePicker
- **Hosting**: DigitalOcean

## Installation

### Prerequisites
- Flutter SDK
- Node.js
- MySQL (Hosted on DigitalOcean or any other cloud service)
- Google Maps API Key

### Steps to Run Locally

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TiareKwong/Waste-Management-Application.git
   cd Waste-Management-Application

2. **Create Database**
   - Database name: `waste_management`
   - Tables: `reports`, `collection_schedule`

3. **Create Tables**
   ```sql
   CREATE TABLE reports (
     id INT AUTO_INCREMENT PRIMARY KEY,
     description TEXT,
     image_url VARCHAR(255),
     latitude DOUBLE,
     longitude DOUBLE,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   CREATE TABLE collection_schedule (
     id INT AUTO_INCREMENT PRIMARY KEY,
     location VARCHAR(255) NOT NULL,
     collection_date DATETIME NOT NULL
   );


4. **Run the project:**
   ```bash
   flutter pub get
   flutter run

