import os, logging, socket
from datetime import datetime, timezone
import pymysql
from flask import Flask, abort, render_template

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
log = logging.getLogger("techworld")

def db():
    return pymysql.connect(
        host=os.environ["DB_HOST"], port=int(os.getenv("DB_PORT", "3306")),
        user=os.environ["DB_USER"], password=os.environ["DB_PASSWORD"],
        database=os.getenv("DB_NAME", "techworld"), connect_timeout=4,
        read_timeout=5, write_timeout=5, autocommit=True,
        cursorclass=pymysql.cursors.DictCursor)

@app.get("/")
def home():
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("""SELECT t.id,t.name,t.slug,t.summary,c.name AS category_name
                FROM technologies t JOIN categories c ON c.id=t.category_id
                WHERE t.is_published=1 ORDER BY t.updated_at DESC LIMIT 6""")
            items=cur.fetchall()
            cur.execute("SELECT COUNT(*) AS n FROM technologies WHERE is_published=1")
            total=cur.fetchone()["n"]
            cur.execute("SELECT COUNT(*) AS n FROM categories")
            categories=cur.fetchone()["n"]
        return render_template("index.html", technologies=items, total=total,
                               category_total=categories, hostname=socket.gethostname())
    except Exception:
        log.exception("Homepage database query failed")
        return render_template("index.html", technologies=[], total=0,
             category_total=0, hostname=socket.gethostname(), db_error=True), 503

@app.get("/technologies")
def technologies():
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("""SELECT t.name,t.slug,t.summary,c.name AS category_name
                FROM technologies t JOIN categories c ON c.id=t.category_id
                WHERE t.is_published=1 ORDER BY t.name""")
            items=cur.fetchall()
        return render_template("technologies.html", technologies=items)
    except Exception:
        log.exception("Technology listing query failed")
        abort(503)

@app.get("/technology/<slug>")
def detail(slug):
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("""SELECT t.*,c.name AS category_name FROM technologies t
                JOIN categories c ON c.id=t.category_id
                WHERE t.slug=%s AND t.is_published=1""", (slug,))
            item=cur.fetchone()
        if not item: abort(404)
        return render_template("detail.html", technology=item)
    except Exception:
        log.exception("Technology detail query failed")
        abort(503)

@app.get("/about")
def about():
    return render_template("about.html")

@app.get("/health")
def health():
    return {"status":"healthy","service":"techworld"}, 200

@app.get("/ready")
def ready():
    try:
        with db() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()
        return {"status":"ready","database":"connected"}, 200
    except Exception:
        log.exception("Readiness check failed")
        return {"status":"not_ready","database":"unavailable"}, 503

@app.get("/error")
def error():
    log.error("Intentional HTTP 500 generated for incident exercise")
    return {"error":"Intentional test error",
            "timestamp":datetime.now(timezone.utc).isoformat()}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("APP_PORT","8080")))
