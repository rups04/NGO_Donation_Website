
const express = require("express");
const app = express();


app.set('view engine', 'ejs');
app.use(express.static("public"));
app.use(express.urlencoded({extended: false}))

app.get("/", function(req, res){
  res.render("donate.ejs")
})

app.get("/donate", function(req, res){
  res.render("donate");
})

app.listen(3000, function() {
  console.log("Server started on port 3000");
});
