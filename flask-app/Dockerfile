FROM ubuntu
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y python3-pip && apt install -y python3-flask && apt install -y python3 && pip install python-dotenv
RUN pip install Flask psycopg2-binary

COPY ./flask-app /app

EXPOSE 80
CMD ["python3", "app.py"]