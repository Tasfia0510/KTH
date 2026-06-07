CREATE TABLE department (
	departmentName varchar(255) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	buildingNr int NOT NULL	
);


CREATE TABLE employee (
    employeeID      int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    mentorID	    int, 
	employeeName	varchar(255) NOT NULL,
	phoneNumber     varchar(255),
	startDate 	    timestamp NOT NULL, 
	departmentName  varchar(255),

	CONSTRAINT  fk_departmentName FOREIGN KEY (departmentName) REFERENCES department(departmentName),
	CONSTRAINT  fk_mentorID FOREIGN KEY (mentorID) REFERENCES employee(employeeID)
); 


CREATE TABLE doctors (
    employeeID 		int NOT NULL, 
    specialization 	varchar(255) NOT NULL, 
    roomNr 		    int NOT NULL, 
      
    PRIMARY KEY(employeeID),  		
    CONSTRAINT fk_doctors_emplyeeID FOREIGN KEY (employeeID) REFERENCES employee(employeeID)	
 
 -- doctors är en weak entitiy eftersom den måste ärva identitet från employee (beroende)
); 


CREATE TABLE nurse (
    employeeID 		int NOT NULL, 
    degree 		    varchar(255) NOT NULL, -- varför är den blå?
	
	PRIMARY KEY(employeeID),
	CONSTRAINT fk_nurse_employeeID FOREIGN KEY (employeeID) REFERENCES employee(employeeID)

-- nurse är en weak entitiy eftersom den måste ärva identitet från employee (beroende)
);


CREATE TABLE patient (
    patientID	    int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    diagnosises 	varchar(255) NOT NULL, 
    patientName 	varchar(255) NOT NULL, 
    age		        int NOT NULL CHECK (age>0) 
);


CREATE TABLE treating (
	employeeID	int NOT NULL, 
	patientID	int NOT NULL, 
	PRIMARY KEY (employeeID, patientID),

	CONSTRAINT fk_doctorID FOREIGN KEY (employeeID) REFERENCES doctors(employeeID),
	CONSTRAINT fk_patientID FOREIGN KEY (patientID) REFERENCES patient(patientID)
); 
