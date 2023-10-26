from flask import Flask, request, render_template, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

# Function to get a database connection.
def get_database_connection():
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("DB_HOSTNAME")
    )
    # Set the schema search path
    cursor = conn.cursor()
    cursor.execute("SET search_path TO public")
    cursor.close()
    return conn

@app.route('/')
def home():
    # This page will have the forms for adding and searching for people
    return render_template('index.html')  # Renders the HTML file with forms

@app.route('/add', methods=['POST'])
def add_person():
    name = request.form['name']
    age = request.form['age']

    response = {}
    try:
        conn = get_database_connection()
        cursor = conn.cursor()
        # Prepared statement for insertion to avoid SQL injection
        cursor.execute("INSERT INTO people (name, age) VALUES (%s, %s)", (name, age))
        conn.commit()
        cursor.close()
        response["success"] = True
    except Exception as e:
        response["success"] = False
        response["error"] = str(e)
    finally:
        if conn is not None:
            conn.close()

    return jsonify(response)

@app.route('/search', methods=['GET'])
def search_person():
    name = request.args.get('name')

    results = []
    try:
        conn = get_database_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        # Prepared statement for searching to avoid SQL injection
        cursor.execute("SELECT * FROM people WHERE name ILIKE %s", (f"%{name}%",))
        results = cursor.fetchall()
        cursor.close()
    except Exception as e:
        results = [{"error": str(e)}]
    finally:
        if conn is not None:
            conn.close()

    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)