from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.configure import settings
from app.core import state
from app.routers import predict, meta

@asynccontextmanager
async def lifespan(app: FastAPI):
    state.load_all()       # runs on startup
    yield
    # anything after yield runs on shutdown (cleanup if needed)

app = FastAPI(title=settings.APP_NAME, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(predict.router)
app.include_router(meta.router)


