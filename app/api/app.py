from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# PostgreSQL configuration
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://notes:notespass@notes-db:5432/notesdb')
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Note model
class Note(db.Model):
    __tablename__ = 'notes'
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content
        }

# Create tables at startup
with app.app_context():
    try:
        db.create_all()
        print("Tables created successfully!")
    except Exception as e:
        print(f"Error creating tables: {e}")


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/notes', methods=['GET'])
def get_notes():
    notes = Note.query.all()
    return jsonify([note.to_dict() for note in notes])

@app.route('/add', methods=['POST'])
def add_note():
    data = request.get_json()
    content = data.get('content')
    
    if not content:
        return jsonify({'error': 'Content is required'}), 400
    
    note = Note(content=content)
    db.session.add(note)
    db.session.commit()
    
    return jsonify(note.to_dict()), 201

@app.route('/delete/<int:id>', methods=['DELETE'])
def delete_note(id):
    note = Note.query.get_or_404(id)
    db.session.delete(note)
    db.session.commit()
    return jsonify({'deleted': True, 'id': id}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
