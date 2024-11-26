const jwt = require("jsonwebtoken");
const pool = require("../model/db.js");
require("dotenv").config();
const KEY = process.env.HASHKEY;
const TOKEN_EXPIRATION_TIME = process.env.EXPIRATION;
const jwtHeader = { algorithm: "HS256" };

const authenticateJWT = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.split(' ')[1];
        let expirationTime = Math.floor(Date.now() / 1000) + parseInt(TOKEN_EXPIRATION_TIME);

        try {
            const decodedToken = jwt.verify(token, KEY, jwtHeader);
            if ((await pool.query(`select * from benutzer where benutzername = '${decodedToken.username}' `)).rowCount >= 1) {
            let userCheck = (await pool.query(`select * from benutzer where benutzername = '${decodedToken.username}'`)).rows
                let payload = {
                    username: decodedToken.username,
                    exp: expirationTime,
                };
                const newToken = jwt.sign(payload, KEY, jwtHeader);
                res.setHeader("Authorization", `Bearer ${newToken}`);
                req.newToken = newToken;
                req.query.userid = userCheck[0].id
                req.loggtuser = { userid: userCheck[0].id, name: userCheck[0].benutzername }
                next();
            } else {
                res.status(401).json({ message: "Nutzer nicht erkannt" });
            }
        } catch (error) {
            console.error("Token-Überprüfung fehlgeschlagen:", error.message);
            res.status(401).json({ message: "Kein gültiger Token / Session abgelaufen" });
        }
    } else {
        res.status(401).json({ message: "Nicht eingeloggt" });
    }
};

module.exports = {
    authenticateJWT,
};