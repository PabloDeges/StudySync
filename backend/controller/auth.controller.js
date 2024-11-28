const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
require("dotenv").config();
const KEY = process.env.HASHKEY;
const TOKEN_EXPIRATION_TIME = process.env.EXPIRATION;
const jwtHeader = { algorithm: "HS256" };
const pool = require("../model/db");



const registierung = async (req, res, next) => {
    try {
        const { username, password } = req.body;
        if((await pool.query(`select benutzername, pwhash from benutzer where benutzername = '${username}'`)).rowCount >= 1){
            res.status(500).json({ message: "Nutzer schon vorhanden" });
        } else {
            const hashedPassword = await bcrypt.hash(password, 10);
            let result = await pool.query(`INSERT INTO benutzer(benutzername, pwhash, studiengangid) VALUES ('${username}','${hashedPassword}',3)`);
            res.status(201).json({"message" : "Regestrieung erfolgreich"});
            //next();
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const login = async (req, res) => {
    try {
        const { username, password } = req.body;
        let expirationTime = Date.now() / 1000 + parseInt(TOKEN_EXPIRATION_TIME);
        let payload = {
            username: username,
            exp: expirationTime,
        };

        if ((await pool.query(`select benutzername, pwhash from benutzer where benutzername = '${username}'`)).rowCount >= 1) {
            const userpw = (await pool.query(`select benutzername, pwhash from benutzer where benutzername = '${username}'`)).rows[0].pwhash
            if (userpw && (await bcrypt.compare(password, userpw))) {
                const token = jwt.sign(payload, KEY, jwtHeader);
                res.status(200).json({ token });
            } else {
                res.status(401).json({ message: "Passwort wurde falsch gewählt" });
            }
        } else {
            res.status(401).json({ message: "Dieser Nutzer exisitiert nicht" })
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message });
    }
};

const authToken = async (req,res) => {
    res.status(200).json({"message":"Erfolgreich eingeloggt"})
}

module.exports = {
    registierung,
    login,
    authToken,
};