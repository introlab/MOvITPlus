# MOvITPlus

This repository contains all the required code and documents to create your own MOvITPlus system.

## MOvIT-Detect
Contains everything to access sensors via I2C and SPI using a raspberry pi zero w and and custom hardware. This code is in C++. All communication with the backend is done over MQTT. It is meant to run on a raspberry pi based on BroadCom bcm2835 CPU.

## MOvIT-Detect-Backend
This is the backend of the system, it uses Node-Red which is simple to modify and adapt to your needs. It takes MQTT as input from MOvIT-Detect and stores data in a MongoDB 2 instance locally. All data is then accesible via GET and POST http request used by MOvIT-Detect-Frontend. It is meant to run on a raspberry pi.

## MOvIT-Detect-Frontend
This is the frontend of the system. This is the part the user and clinician interacts with. It is written using React and Redux. It displays data stored by MOvIT-Detect-Backend for further analysis.

## MOvIT-Hardware
Contains all the files to recreate the complete hardware. The altium PCB files, enclosure CAD and STL as well as a bill of material for each sensor needed for the complete system.