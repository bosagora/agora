const express = require('express');
const crypto = require("crypto");
const router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.post('/login', function (req, res, next) {
  res.setHeader("Content-Type", "application/json");
  res.end(
      JSON.stringify({
        status: 0,
        data: "md+31zMRMVqPgR9b99kSCEWZdIIdFUREO38ok6oFX50=",
      })
  );
})

router.post('/admin/validator', function (req, res, next) {
  res.setHeader("Content-Type", "application/json");
  res.end(
      JSON.stringify({
        private_key: "SBFLURYJRXVJDQRQSTSGDEKI6HDQE4R6QKYJXNULFXX4PEHVIJCAQ3IV",
        voter_card: {
          validator: crypto.randomBytes(64).toString("hex"),
          address: "boa1" + crypto.randomBytes(64).toString("hex"),
          expires: "2021-11-03T02:08:14Z",
          signature: crypto.randomBytes(128).toString("hex"),
        },
      })
  );
})

router.post('/admin/encryptionkey', function (req, res, next) {
  res.setHeader("Content-Type", "application/json");
  res.end(
      JSON.stringify({
        private_key: "encryption key TEST DATA",
        voter_card: {
          validator: "ADMIN VALIDATOR",
          address: "boa1" + crypto.randomBytes(64).toString("hex"),
          expires: "2021-11-03T02:08:14Z",
          signature: "0x"+crypto.randomBytes(128).toString("hex"),
        },
      })
  );;
})

module.exports = router;
