# 🎬 IMDb Movie Database SQL Project

This project provides a fully structured SQL schema to simulate an IMDb-style movie database system. It includes table definitions for movies, actors, directors, genres, ratings, and their relationships.

---

## 📌 Overview

The goal of this project is to create a normalized relational database structure that models real-world movie data. It is ideal for practicing SQL query writing, understanding database normalization, and building backend systems for movie-related applications.

---

## 🗃️ Schema Features

The database schema includes:

- **Movies**: Title, year, and identifiers
- **Actors & Directors**: Names and IDs
- **Genres**: Film genres associated with each movie
- **Ratings**: Viewer ratings and review counts
- **Relationships**: Movie cast, direction teams, genre mapping

---

## 🧱 Tables Included

| Table Name        | Description                                |
|-------------------|--------------------------------------------|
| `movie`           | Contains basic information about movies    |
| `actor`           | Contains details about actors              |
| `director`        | Contains details about directors           |
| `genre`           | Contains list of movie genres              |
| `movie_genre`     | Maps movies to their genres                |
| `movie_cast`      | Maps actors to the movies they acted in    |
| `movie_direction` | Maps directors to the movies they directed |
| `rating`          | Stores rating information for movies       |

---

## 🚀 Getting Started

### Prerequisites

- MySQL or compatible SQL engine installed (e.g., MariaDB, PostgreSQL with minor syntax tweaks)
- SQL client like MySQL Workbench or command-line interface

### Setup

1. Clone the repository:

```bash
git clone https://github.com/Aditya-raj123/imdb-sql-project.git
cd imdb-sql-project

Import the SQL file:
mysql -u your_username -p your_database < "imbd project.sql"

Run queries to interact with the schema.

🧪 Example Use Cases
Query movies by a specific director
Find top-rated movies in a genre
Analyze collaboration between actors and directors
Practice JOINs, GROUP BYs, and subqueries

📁 imdb-sql-project/
├── imbd project.sql     # SQL schema file
└── README.md            # Project documentation

🙌 Contributing
Feel free to fork this project, suggest improvements, or add sample data and queries.

👨‍💻 Author
Aditya Raj – GitHub Profile
