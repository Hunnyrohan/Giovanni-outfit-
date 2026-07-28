def test_health_get(client):
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "ai-service"
    assert "model_name" in body


def test_health_post(client):
    response = client.post("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
