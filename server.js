const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();


const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public'));


//config
const dbConfig = {
	user: process.env.DB_USER,
	server: process.env.DB_SERVER,
	database: process.env.DB_DATABASE,
	password: process.env.DB_PASS,
	options: {
		encrypt: false,
		trustServerCertificate: true
	}
};


//testing
sql.connect(dbConfig)
	.then(pool => {
		if (pool.connecting) console.log('Connecting to MSSQL...');
		if (pool.connected) console.log('Connected to MSSQL successfully!');
	})
	.catch(err => console.error('Database connection failed:', err));


//get READ
app.get('/api/students', async (req, res) => {
	try {
		const result = await sql.query`SELECT StudentID, FirstName, LastName, Age FROM Students`;
		res.json(result.recordset);
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.get('/api/students_details', async (req, res) => {
	try {
		const result = await sql.query`EXEC GetStudentsDetails`;
		res.json(result.recordset);
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.get('/api/sections', async (req, res) => {
	try {
		const result = await sql.query`SELECT * FROM Sections`;
		res.json(result.recordset);
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

//post CREATE
app.post('/api/add_student', async (req, res) => {
	try {
		const { firstName, lastName, age, section } = req.body;

		//validate
		if (!firstName || !lastName || !section) {
			return res.status(400).json({ error: 'Missing required fields (firstName, lastName, age, section)' });
		}

		//params to prevent SQL Injection
		let pool = await sql.connect()
		let result = await pool.request()
			.input('FirstName', sql.VarChar(50), firstName)
			.input('LastName', sql.VarChar(50), lastName)
			.input('Age', sql.Int, age || null)
			.input('Section', sql.Int, section)
			.query(`
                INSERT INTO Students (FirstName, LastName, SectionID, Age) 
                VALUES (@FirstName, @LastName, @Section, @Age);
            `);

		//newly generated ID from the query response
		// const newID = result.recordset[0].StudentID;

		// Send success response back to the client
		res.status(201).json({
			message: 'Customer created successfully!'
		});

	} catch (err) {
		console.error('Database insertion error:', err);
		res.status(500).json({ error: 'Internal Server Error' });
	}
});


//DELETE
app.post('/api/remove_student', async (req, res) => {
	try {
		const { studentID } = req.body;

		//validate
		if (!studentID) {
			return res.status(400).json({ error: 'Missing required fields (studentID)' });
		}

		//params to prevent SQL Injection
		let pool = await sql.connect()
		let result = await pool.request()
			.input('StudentID', sql.Int, studentID)
			.query(`
                DELETE FROM Students
				WHERE StudentID = @StudentID
            `);

		//newly generated ID from the query response
		// const newID = result.recordset[0].StudentID;

		// Send success response back to the client
		res.status(201).json({
			message: 'Customer created successfully!'
		});

	} catch (err) {
		console.error('Database insertion error:', err);
		res.status(500).json({ error: 'Internal Server Error' });
	}
});


//UPDATE
app.post('/api/update_student', async (req, res) => {
	try {
		const { studentID, firstName, lastName, age, section } = req.body;

		//validate
		if (!studentID || !firstName || !lastName || !section) {
			return res.status(400).json({ error: 'Missing required fields' });
		}

		//params to prevent SQL Injection
		let pool = await sql.connect()
		let result = await pool.request()
			.input('StudentID', sql.Int, studentID)
			.input('FirstName', sql.VarChar(100), firstName)
			.input('LastName', sql.VarChar(100), lastName)
			.input('Age', sql.Int, age || null)
			.input('SectionID', sql.Int, section)
			.query(`
                UPDATE Students
				SET FirstName = @FirstName,
					LastName = @LastName,
					Age = @Age,
					SectionID = @SectionID
				WHERE StudentID = @StudentID
            `);

		//newly generated ID from the query response
		// const newID = result.recordset[0].StudentID;

		// Send success response back to the client
		res.status(201).json({
			message: 'Customer created successfully!'
		});

	} catch (err) {
		console.error('Database insertion error:', err);
		res.status(500).json({ error: 'Internal Server Error' });
	}
});

app.post('/api/get_student', async (req, res) => {
	try {
		const { studentID } = req.body;

		//validate
		if (!studentID) {
			return res.status(400).json({ error: 'Missing required fields (studentID)' });
		}

		//params to prevent SQL Injection
		let pool = await sql.connect()
		let result = await pool.request()
			.input('StudentID', sql.Int, studentID)
			.query(`
                SELECT * FROM Students
				WHERE StudentID = @StudentID
            `);

		//newly generated ID from the query response
		// const newID = result.recordset[0].StudentID;

		// Send success response back to the client
		res.json(result.recordset);

	} catch (err) {
		console.error('Database insertion error:', err);
		res.status(500).json({ error: 'Internal Server Error' });
	}
});


//port listening
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));