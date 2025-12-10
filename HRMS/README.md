# HRMS Application

Human Resource Management System built with FastAPI (Python) backend and React frontend.

## Structure

```
HRMS/
├── hrms-api/              # FastAPI backend
│   ├── Dockerfile         # API container image
│   ├── main.py           # FastAPI application
│   ├── database.py       # Database connection
│   ├── requirements.txt  # Python dependencies
│   ├── models/           # Database models & schemas
│   └── routers/          # API endpoints
│
├── hrms-web/             # React frontend
│   ├── Dockerfile        # Web container image
│   ├── nginx-internal.conf  # Nginx configuration
│   ├── package.json      # Node dependencies
│   └── src/              # React application
│
├── .env.template         # Environment configuration template
├── .dockerignore         # Docker ignore patterns
└── README.md            # This file
```

## Technology Stack

**Backend:**
- Python 3.11
- FastAPI
- PostgreSQL 15
- SQLAlchemy
- Pydantic

**Frontend:**
- React 18
- Axios
- React Router

## Deployment

This application is deployed as part of the multi-app deployment setup.

**See: `../multi-app-deployment/` for deployment instructions**

## Local Development

For local development of HRMS only:

1. Set up database:
```bash
docker run -d -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=testdb \
  postgres:15-alpine
```

2. Run API:
```bash
cd hrms-api
pip install -r requirements.txt
uvicorn main:app --reload
```

3. Run frontend:
```bash
cd hrms-web
npm install
npm start
```

## Environment Variables

Copy `.env.template` to `.env` and configure:

- `POSTGRES_USER` - Database username
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name
- `DATABASE_URL` - PostgreSQL connection string
- `PORT` - API port (default: 8000)
- `ENVIRONMENT` - Deployment environment (dev/production)

## API Endpoints

- `/` - Welcome endpoint
- `/health` - Health check
- `/docs` - Swagger API documentation
- `/api/v1/employees/` - Employee management
- `/api/v1/departments/` - Department management
- `/api/v1/leaves/` - Leave request management

## Features

- ✅ Employee CRUD operations
- ✅ Department management
- ✅ Leave request tracking
- ✅ PostgreSQL database
- ✅ RESTful API
- ✅ Interactive API documentation
- ✅ Health checks
- ✅ CORS support
