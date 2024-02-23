const express = require("express");
const mysql = require("mysql");
const util = require("util");
const path = require("path");
const ejs = require("ejs");
const parser = require("body-parser");
const multer = require('multer');
const fs = require("fs");
const { NEWDECIMAL } = require("mysql/lib/protocol/constants/types");

// database connection
const PORT = 8000;
const DB_HOST = "localhost";
const DB_USER = "root";
const DB_NAME = "coursework";
const DB_PASSWORD = "";
const DB_PORT = 3306;

var connection = mysql.createConnection({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    port: DB_PORT,
});

connection.query = util.promisify(connection.query).bind(connection);

connection.connect(function (err) {
    if (err) {
        console.error("error connecting: " + err.stack);
        return;
    }

    console.log("Connected.");
});

// file upload

const storage = multer.diskStorage({
    destination: (req, file, cb)=>{
      cb(null, __dirname + '/public');
    },

    filename: (req, file, cb)=>{
      console.log(file);
      cb(null, file.originalname);
    }
})

const upload = multer({ storage: storage });

// express 
const app = express();

app.set("view engine", "ejs");
app.use(express.static("public"));
app.use(parser.urlencoded({ extended : false }));

// homepage
app.get("/", async (req, res) => {

    const societies = await connection.query("SELECT COUNT(*) AS count FROM Society");
    const members = await connection.query("SELECT COUNT(*) AS count FROM Members");
    const hobby = await connection.query("SELECT COUNT(*) AS count FROM Hobby");

    res.render("index", {
        societies : societies[0].count,
        members : members[0].count,
        memberships : '?',
        hobbies : hobby[0].count,
    });
});

app.get("/societies", async (req, res) => {

    const societies = await connection.query("SELECT Society.SOC_ID, Soc_Title, Soc_Email, Soc_MembershipFee, COUNT(MEMBER_ID) AS count FROM Society LEFT JOIN SocietyMember ON Society.SOC_ID = SocietyMember.SOC_ID GROUP BY Soc_Title");

    res.render("societies", {
        societies : societies,
    });
});

app.get("/societies/delete-:id", async (req, res) => {
    console.log("hey i am gonna delete this :)");
    await connection.query("DELETE FROM Society WHERE SOC_ID = ?", req.params.id)

    res.redirect("/societies");
});

app.get("/view/:id", async (req, res) => {
    
    const society = await connection.query("SELECT Society.SOC_ID, Soc_Title, Soc_Email, Soc_MembershipFee, COUNT(MEMBER_ID) AS count FROM Society LEFT JOIN SocietyMember ON Society.SOC_ID = SocietyMember.SOC_ID WHERE Society.SOC_ID = ? GROUP BY Soc_Title", [req.params.id]);
    const signatory = await connection.query("SELECT CONCAT(Stu_FName, ' ', Stu_LName) AS 'Name', Title FROM Student INNER JOIN Members ON Student.URN = Members.URN INNER JOIN Committee_Member ON Members.MEMBER_ID = Committee_Member.MEMBER_ID INNER JOIN Society ON Committee_Member.SOC_ID = Society.SOC_ID WHERE Signatory = TRUE AND Society.SOC_ID = ?", [req.params.id]);
    const committee = await connection.query("SELECT CONCAT(Stu_FName, ' ', Stu_LName) AS 'Name', Title FROM Student INNER JOIN Members ON Student.URN = Members.URN INNER JOIN Committee_Member ON Members.MEMBER_ID = Committee_Member.MEMBER_ID INNER JOIN Society ON Committee_Member.SOC_ID = Society.SOC_ID WHERE Signatory = FALSE AND Society.SOC_ID = ?", [req.params.id]);
    
    res.render("view", {
        society : society[0],
        signatory : signatory,
        committee : committee,
    })
})

app.get("/update/:id", async (req, res) => {
    
    const society = await connection.query("SELECT SOC_ID, Soc_Title, Soc_Email, Soc_MembershipFee FROM Society WHERE Society.SOC_ID = ?", [req.params.id]);

    res.render("update", {
        society : society[0],
        message : "",
    })
})

app.post("/update/:id", async (req, res) => {
    message = "";
    pass = true;
    const fee = /\d{1,2}(.\d{1,2}?)?/;
    const email = /ussu\.[A-Za-z0-9]+@surrey\.ac\.uk/;

    const emptyFee = (req.body.Soc_MembershipFee).trim() == "";
    const emptyEmail = (req.body.Soc_Email).trim() == "";
    const emptyTitle = (req.body.Soc_Title).trim() == "";

    if (!fee.test(req.body.Soc_MembershipFee) && !emptyFee) {
        message = "Invalid Fee";
        pass = false;
    } 

    if (!email.test(req.body.Soc_Email) && !emptyEmail) {
        message = "Invalid Email";
        pass = false;
    } 

    if (pass && !(emptyTitle && emptyFee && emptyEmail)) {       
        if (!emptyTitle) {
            await connection.query("UPDATE Society SET Soc_Title = ? WHERE SOC_ID = ?", [req.body.Soc_Title, req.params.id]);
        }
        
        if (!emptyFee) {
            await connection.query("UPDATE Society SET Soc_MembershipFee = ? WHERE SOC_ID = ?", [req.body.Soc_MembershipFee, req.params.id]);
        }

        if (!emptyEmail) {
            await connection.query("UPDATE Society SET soc_Email = ? WHERE SOC_ID = ?", [req.body.Soc_Email, req.params.id]);
        }
        message = "Updated successfully!"
    }

    const society = await connection.query("SELECT SOC_ID, Soc_Title, Soc_Email, Soc_MembershipFee FROM Society WHERE Society.SOC_ID = ?", [req.params.id]);

    res.render("update", {
        society : society[0],
        message : message,
    })
})

app.get("/create", async (req, res) => {
    res.render("create", {message : ""})
})

app.post("/create", upload.single('image'), async (req, res) => {
    message = "";
    const fee = /\d{1,2}(.\d{1,2}?)?/;
    const email = /ussu\.[A-Za-z0-9]+@surrey\.ac\.uk/;

    if (!fee.test(req.body.Soc_MembershipFee) || !email.test(req.body.Soc_Email)) {
        message = "Invalid entry!"
    } else {
        console.log(req.body);
        await connection.query("INSERT INTO Society(Soc_Title, Soc_Email, Soc_MembershipFee) VALUES (?, ?, ?)", [
            req.body.Soc_Title, req.body.Soc_Email, req.body.Soc_MembershipFee
        ]);

        const newID = await connection.query("SELECT MAX(SOC_ID) AS newID FROM SOCIETY");
        console.log(newID[0].newID);
        fs.rename(__dirname + "/public/" + req.file.filename, __dirname + "/public/" + newID[0].newID + ".jpg", (err) => {
            if (err) {
                console.log("error:" + err);
            }
        })

        message = "Created successfully!";
    }

    res.render("create", {message : message,})
})

app.use(function (req, res, next) {
    res.status(404).render("error")
})

app.listen(PORT, () => {
    console.log(`Listening at http://localhost:${PORT}`);

});
