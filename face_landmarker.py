# filename: face_landmarker_studio_like_net.py
# MediaPipe Tasks - Face Landmarker webcam demo (Studio-like)
# Works with mediapipe==0.10.21; auto-fetches face_mesh_connections from GitHub if missing.

import os
import sys
import time
import re
import requests
import numpy as np
import cv2

MODEL_URL = ("https://storage.googleapis.com/mediapipe-models/face_landmarker/"
             "face_landmarker/float16/1/face_landmarker.task")
MODEL_PATH = "face_landmarker.task"

def ensure_model():
    if os.path.exists(MODEL_PATH):
        return
    print("[INFO] Downloading model...")
    r = requests.get(MODEL_URL, timeout=60)
    r.raise_for_status()
    with open(MODEL_PATH, "wb") as f:
        f.write(r.content)
    print("[INFO] Model saved:", MODEL_PATH)

# ---------- robust connectors loader ----------
def load_connectors():
    """
    Try importing official connectors; if not present (mediapipe 0.10.21 tasks-only),
    fetch face_mesh_connections.py from GitHub and exec to obtain:
      FACEMESH_TESSELATION, FACEMESH_CONTOURS, FACEMESH_IRISES
    Fallback to small demo sets if network fails.
    """
    # 1) direct import (works on versions that still ship solutions)
    try:
        from mediapipe.solutions import face_mesh_connections as fmc
        print("[INFO] Using connectors from mediapipe.solutions.face_mesh_connections")
        return fmc.FACEMESH_TESSELATION, fmc.FACEMESH_CONTOURS, fmc.FACEMESH_IRISES
    except Exception:
        pass

    # 2) fetch from GitHub raw
    urls = [
        # main branch
        "https://raw.githubusercontent.com/google/mediapipe/master/mediapipe/python/solutions/face_mesh_connections.py",
        # fallback to older path if needed
        "https://raw.githubusercontent.com/google/mediapipe/v0.10.14/mediapipe/python/solutions/face_mesh_connections.py",
    ]
    for url in urls:
        try:
            print("[INFO] Fetching connectors from:", url)
            resp = requests.get(url, timeout=30)
            resp.raise_for_status()
            code = resp.text
            # Execute the module code in isolated dict
            g = {}
            exec(code, g, g)
            tess = g.get("FACEMESH_TESSELATION", None)
            cont = g.get("FACEMESH_CONTOURS", None)
            iris = g.get("FACEMESH_IRISES", None)
            if tess and cont and iris:
                print("[INFO] Loaded connectors from GitHub:",
                      "tess=", len(tess), "contours=", len(cont), "irises=", len(iris))
                return tess, cont, iris
        except Exception as e:
            print("[WARN] Fetch failed:", e)

    # 3) last-resort minimal sets (still shows lines, just fewer)
    print("[WARN] Falling back to minimal built-in connectors.")
    tess = set([
        (127, 34), (34, 139), (139, 127), (11, 0), (0, 37), (37, 11),
        (232, 231), (231, 120), (120, 232), (128, 121), (121, 47), (47, 128)
    ])
    cont = set([
        (10, 338), (338, 297), (297, 332), (332, 284),
        (284, 251), (251, 389), (389, 356), (356, 454),
        (454, 323), (323, 361), (361, 288), (288, 397),
        (397, 365), (365, 379), (379, 378), (378, 400),
        (400, 377), (377, 152), (152, 148), (148, 176),
        (176, 149), (149, 150), (150, 136), (136, 172),
        (172, 58),  (58, 132),  (132, 93),  (93, 234),
        (234, 127), (127, 162), (162, 21),  (21, 54),
        (54, 103),  (103, 67),  (67, 109)
    ])
    iris = set([
        (474, 475), (475, 476), (476, 477), (477, 474),  # right
        (469, 470), (470, 471), (471, 472), (472, 469)   # left
    ])
    return tess, cont, iris

# drawing
def draw_landmarks(img, lms, draw_points=True, draw_mesh=False, draw_contours=True, draw_irises=True,
                   TESS=None, CONT=None, IRIS=None):
    if not lms:
        return
    h, w = img.shape[:2]
    pts = [(int(p.x * w), int(p.y * h)) for p in lms]

    if draw_points:
        for (x, y) in pts:
            cv2.circle(img, (x, y), 1, (0, 255, 0), -1, cv2.LINE_AA)

    def draw(connections, thick):
        if not connections:
            return
        for i, j in connections:
            if 0 <= i < len(pts) and 0 <= j < len(pts):
                cv2.line(img, pts[i], pts[j], (0, 255, 255), thick, cv2.LINE_AA)

    if draw_mesh:
        draw(TESS, 1)
    if draw_contours:
        draw(CONT, 2)
    if draw_irises:
        draw(IRIS, 2)

def put_blendshape_panel(img, face_idx, blendshapes, topk=8, x=10, y=10):
    if not blendshapes:
        return y
    top = sorted(blendshapes, key=lambda b: b.score, reverse=True)[:topk]
    line_h, panel_w = 18, 320
    panel_h = line_h * (len(top) + 2)
    overlay = img.copy()
    cv2.rectangle(overlay, (x-6, y-6), (x-6+panel_w, y-6+panel_h), (0,0,0), -1)
    img[:] = cv2.addWeighted(overlay, 0.35, img, 0.65, 0)
    cv2.putText(img, f"Face {face_idx}  BlendShapes", (x, y),
                cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255,255,255), 1, cv2.LINE_AA)
    y += line_h
    for b in top:
        name, score = b.category_name, b.score
        bar_w = int(min(max(score, 0.0), 1.0) * 200)
        cv2.putText(img, f"{name[:18]:18s} {score:>5.2f}", (x, y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.45, (200,255,200), 1, cv2.LINE_AA)
        cv2.rectangle(img, (x+165, y-12), (x+365, y-4), (60,60,60), 1, cv2.LINE_AA)
        cv2.rectangle(img, (x+165, y-12), (x+165+bar_w, y-4), (0,200,255), -1, cv2.LINE_AA)
        y += line_h
    return y + 10

def main():
    import mediapipe as mp
    print("[INFO] mediapipe version:", getattr(mp, "__version__", "unknown"))

    # Tasks API (0.10.21)
    from mediapipe.tasks import python as mp_python   # BaseOptions lives here
    from mediapipe.tasks.python import vision
    from mediapipe.tasks.python.vision import FaceLandmarker, FaceLandmarkerOptions
    try:
        from mediapipe.tasks.python.vision import VisionRunningMode
        HAS_RUNNING_MODE = True
    except Exception:
        HAS_RUNNING_MODE = False

    # MP Image wrapper (fixes 'Please provide image_format with data')
    MPImage = mp.Image
    ImageFormat = mp.ImageFormat

    # connectors
    TESS, CONT, IRIS = load_connectors()
    print(f"[DEBUG] connectors: tess={len(TESS)}  contours={len(CONT)}  irises={len(IRIS)}")

    ensure_model()

    # webcam
    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW) if sys.platform.startswith("win") else cv2.VideoCapture(0)
    if not cap.isOpened():
        print("[ERROR] Cannot open webcam.")
        return

    # settings (default like Studio: 轮廓/虹膜开，网格可按 m 开)
    num_faces = 1
    show_points   = True
    show_mesh     = True   # 直接默认开网格；若卡顿可按 m 关掉
    show_contours = True
    show_irises   = True
    show_blend    = True

    base_options = mp_python.BaseOptions(model_asset_path=MODEL_PATH)

    def make_landmarker(nfaces):
        if HAS_RUNNING_MODE:
            opts = FaceLandmarkerOptions(
                base_options=base_options,
                running_mode=VisionRunningMode.VIDEO,
                num_faces=nfaces,
                output_face_blendshapes=True,
                output_facial_transformation_matrixes=True
            )
        else:
            opts = FaceLandmarkerOptions(
                base_options=base_options,
                num_faces=nfaces,
                output_face_blendshapes=True,
                output_facial_transformation_matrixes=True
            )
        return FaceLandmarker.create_from_options(opts)

    landmarker = make_landmarker(num_faces)

    print("[INFO] Controls: q=quit  p=points  m=mesh  o=contours  i=irises  b=blendshapes  f=faces(1-3)")
    prev_ts = 0
    while True:
        ok, frame_bgr = cap.read()
        if not ok:
            break

        # Optional front-camera mirror:
        # frame_bgr = cv2.flip(frame_bgr, 1)

        h, w = frame_bgr.shape[:2]
        frame_rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
        frame_rgb = np.ascontiguousarray(frame_rgb)

        mp_image = MPImage(image_format=ImageFormat.SRGB, data=frame_rgb)

        ts_ms = int(time.time() * 1000)
        if ts_ms == prev_ts:
            ts_ms += 1
        prev_ts = ts_ms

        if HAS_RUNNING_MODE:
            result = landmarker.detect_for_video(mp_image, ts_ms)
        else:
            result = landmarker.detect(mp_image)

        if result and result.face_landmarks:
            for fi, lms in enumerate(result.face_landmarks):
                draw_landmarks(
                    frame_bgr, lms,
                    draw_points=show_points,
                    draw_mesh=show_mesh,
                    draw_contours=show_contours,
                    draw_irises=show_irises,
                    TESS=TESS, CONT=CONT, IRIS=IRIS
                )
            if show_blend and result.face_blendshapes:
                y = 10
                for fi, bs in enumerate(result.face_blendshapes):
                    y = put_blendshape_panel(frame_bgr, fi, bs, topk=8, x=10, y=y)

        hud = f"Faces:{num_faces}  Points:{int(show_points)}  Mesh:{int(show_mesh)}  Contours:{int(show_contours)}  Irises:{int(show_irises)}  Blend:{int(show_blend)}"
        cv2.putText(frame_bgr, hud, (10, h-12), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255,255,255), 1, cv2.LINE_AA)

        cv2.imshow("MediaPipe Face Landmarker - Studio-like Demo", frame_bgr)
        k = cv2.waitKey(1) & 0xFF
        if k == ord('q'):
            break
        elif k == ord('p'):
            show_points = not show_points
        elif k == ord('m'):
            show_mesh = not show_mesh
        elif k == ord('o'):
            show_contours = not show_contours
        elif k == ord('i'):
            show_irises = not show_irises
        elif k == ord('b'):
            show_blend = not show_blend
        elif k == ord('f'):
            num_faces = 1 if num_faces >= 3 else num_faces + 1
            landmarker = make_landmarker(num_faces)

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
