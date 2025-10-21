import cv2
import mediapipe as mp

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_style = mp.solutions.drawing_styles

def main():
    cap = cv2.VideoCapture(0)  # 0 为默认摄像头
    if not cap.isOpened():
        print("Cannot open camera")
        return

    # 静态或视频模式下都可用，min_detection_confidence/track_confidence 可按需调整
    with mp_hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5
    ) as hands:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Cannot receive frame (stream end?). Exiting ...")
                break

            # OpenCV 读取为 BGR，MediaPipe 需要 RGB
            img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # 可选：提升性能，声明为只读
            img_rgb.flags.writeable = False
            results = hands.process(img_rgb)
            img_rgb.flags.writeable = True

            # 在原 BGR 图像上画关键点与连线
            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    mp_drawing.draw_landmarks(
                        frame,
                        hand_landmarks,
                        mp_hands.HAND_CONNECTIONS,
                        mp_style.get_default_hand_landmarks_style(),
                        mp_style.get_default_hand_connections_style()
                    )

            cv2.imshow('Hand Keypoints (Press q to quit)', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
