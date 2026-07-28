import os
import time


def _wait_for_completion(client, job_id: str, timeout_seconds: float = 5.0) -> dict:
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        response = client.get(f"/virtual-tryon/status/{job_id}")
        assert response.status_code == 200
        body = response.json()
        if body["status"] in ("COMPLETED", "FAILED"):
            return body
        time.sleep(0.1)
    raise AssertionError(f"Job {job_id} did not finish within {timeout_seconds}s")


def _create_job(client, sample_image_bytes: bytes) -> dict:
    files = {
        "person_image": ("person.png", sample_image_bytes, "image/png"),
        "garment_image": ("garment.png", sample_image_bytes, "image/png"),
    }
    response = client.post("/virtual-tryon", files=files)
    assert response.status_code == 202
    return response.json()


def test_create_job_returns_pending_or_processing(client, sample_image_bytes):
    body = _create_job(client, sample_image_bytes)
    assert body["status"] in ("PENDING", "PROCESSING")
    assert body["providerName"] == "leffa"
    assert body["jobId"]


def test_job_completes_and_produces_result(client, sample_image_bytes):
    created = _create_job(client, sample_image_bytes)
    final = _wait_for_completion(client, created["jobId"])

    assert final["status"] == "COMPLETED"
    assert final["imageUrl"].startswith("/outputs/")
    assert final["processingTime"] is not None and final["processingTime"] >= 0

    output_dir = os.environ["OUTPUT_DIR"]
    filename = final["imageUrl"].removeprefix("/outputs/")
    assert os.path.exists(os.path.join(output_dir, filename))


def test_history_lists_created_jobs(client, sample_image_bytes):
    created = _create_job(client, sample_image_bytes)
    _wait_for_completion(client, created["jobId"])

    response = client.get("/virtual-tryon/history")
    assert response.status_code == 200
    body = response.json()
    assert body["total"] >= 1
    assert any(job["jobId"] == created["jobId"] for job in body["jobs"])


def test_delete_job_then_status_is_404(client, sample_image_bytes):
    created = _create_job(client, sample_image_bytes)
    _wait_for_completion(client, created["jobId"])

    delete_response = client.delete(f"/virtual-tryon/{created['jobId']}")
    assert delete_response.status_code == 204

    status_response = client.get(f"/virtual-tryon/status/{created['jobId']}")
    assert status_response.status_code == 404
    assert status_response.json()["success"] is False


def test_status_for_unknown_job_is_404(client):
    response = client.get("/virtual-tryon/status/does-not-exist")
    assert response.status_code == 404


def test_rejects_non_image_upload(client):
    files = {
        "person_image": ("person.txt", b"not an image", "text/plain"),
        "garment_image": ("garment.png", b"fake", "image/png"),
    }
    response = client.post("/virtual-tryon", files=files)
    assert response.status_code == 400
    assert response.json()["success"] is False
