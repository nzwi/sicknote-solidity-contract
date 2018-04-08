/*
* Title: Simple Ethereum Contract To Manage Sick Notes
* Version: 00_01
* Author: Nzwisisa Chidembo <nzwisisa@gmail.com>
*/

pragma solidity ^0.4.17;

contract SickNote {
    address public administrator;
    uint public noteIndex;

    struct Doctor {
        string firstName;
        string lastName;
        string physicalAddress;
        string phoneNo;
        bool isValue;
    }

    mapping (uint => Doctor) public doctors;

    struct Patient {
        string firstName;
        string lastName;
        bool isValue;
        uint[] notes;
    }

    mapping (uint => Patient) public patients;

    struct Note {
        uint practiceNo;
        uint timeStamp;
        uint sickDays;
        string illnessDescription;
    }

    mapping (uint => Note) public notes;

    function SickNote() public {
        administrator = msg.sender;
        noteIndex = 0;
    }

    modifier restricted_admin() {
        require(msg.sender == administrator);
        _;
    }

    modifier restricted_doctor(uint practiceNo) {
        require(doctors[practiceNo].isValue);
        _;
    }

    modifier restricted_patient_overwrite(uint patientId) {
        require(!patients[patientId].isValue); //restrict patient data from being overwritten
        _;
    }

    function addDoctor(uint practiceNo, string firstName, string lastName, string physicalAddress, string phoneNo) public restricted_admin {
        doctors[practiceNo] = Doctor(firstName, lastName, physicalAddress, phoneNo, true);
    }

    function addPatient(uint practiceNo, uint patientId, string firstName, string lastName) public restricted_doctor(practiceNo) restricted_patient_overwrite(patientId) {
        patients[patientId] = Patient(firstName, lastName, true, new uint[](0));
    }

    function addNote(uint practiceNo, uint patientId, uint sickDays, string illnessDescription) public restricted_doctor(practiceNo) {
        Patient p = patients[patientId];
        p.notes.push(noteIndex);
        notes[noteIndex] = Note({practiceNo: practiceNo, timeStamp: block.timestamp, sickDays: sickDays, illnessDescription: illnessDescription});
        noteIndex++;
    }

    function getLastSickNote(uint patientId) public view returns (uint, uint, uint, string) {
        Patient p = patients[patientId];
        uint lastNoteIndex = p.notes[p.notes.length - 1];
        return (notes[lastNoteIndex].practiceNo, notes[lastNoteIndex].timeStamp, notes[lastNoteIndex].sickDays, notes[lastNoteIndex].illnessDescription);
    }
}
