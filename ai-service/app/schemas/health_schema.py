from datetime import datetime

from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str = "ok"
    service: str = "ai-service"
    model_name: str
    model_device: str
    timestamp: datetime
