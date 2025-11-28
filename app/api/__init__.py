import os
from flask import Flask, request, jsonify
from .models import db, migrate, User
def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL","sqlite:///local.db")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    db.init_app(app)
    migrate.init_app(app, db)
    
    @app.route("/health")
    def health():
        return {"status": "ok"}, 200
    
    @app.route("/users", methods=["POST"])
    def create_user():
        try:
            data = request.get_json()
            if not data or "name" not in data or "email" not in data:
                return jsonify({"error": "Invalid input"}), 400

            u = User(name=data["name"], email=data["email"])
            db.session.add(u)
            db.session.commit()
            return jsonify(u.to_dict()), 201
        except Exception as e:
            db.session.rollback()
            print("❌ ERROR:", e)
            return jsonify({"error": str(e)}), 500

    
    @app.route("/users", methods=["GET"])
    def list_users():
        return jsonify([u.to_dict() for u in User.query.all()])
    
    @app.route("/users/<int:id>", methods=["PUT"])
    def update_user(id):
        u = User.query.get_or_404(id)
        data = request.get_json()
        u.name = data.get("name", u.name)
        u.email = data.get("email", u.email)
        db.session.commit()
        return jsonify(u.to_dict())
    
    @app.route("/users/<int:id>", methods=["DELETE"])
    def delete_user(id):
        u = User.query.get_or_404(id)
        db.session.delete(u)
        db.session.commit()
        return {"deleted": True}
    return app