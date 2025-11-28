from flask import Flask, request, jsonify
from models import db, Note

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///local.db"
db.init_app(app)

@app.route("/notes", methods=["GET"])
def get_notes():
    return jsonify([n.to_dict() for n in Note.query.all()])

@app.route("/add", methods=["POST"])
def add_note():
    content = request.json.get("content")
    n = Note(content=content)
    db.session.add(n)
    db.session.commit()
    return n.to_dict(), 201

@app.route("/delete/<int:id>", methods=["DELETE"])
def delete(id):
    n = Note.query.get_or_404(id)
    db.session.delete(n)
    db.session.commit()
    return {"deleted": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
