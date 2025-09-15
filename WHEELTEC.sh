udevadm info /dev/ttyACM0 
sudo chmod 777 ./src/step_motor/ch9012_udev.sh
sudo ./src/step_motor/ch9012_udev.sh

conda deactivate  
colcon build  
source ./install/setup.zsh

# keyboard control
ros2 run step_motor motor_node 
ros2 run wheeltec_robot_keyboard wheeltec_keyboard
ros2 topic echo /motor_state

# position control
ros2 run step_motor motor_node
ros2 topic pub --once /motor_control step_motor/msg/Motor "{id: 1, speed: 100, dir: 0, mode: 4, angle: 900, state: 0, sub_divide: 8}"
ros2 topic pub --once /motor_control step_motor/msg/Motor "{id: 1,speed: 200,dir: 0,mode: 2,angle: 30000,state: 0,sub_divide: 32}"
ros2 topic pub --once /motor_control step_motor/msg/Motor "{id: 1,speed: 200,dir: 1,mode: 2,angle: 30000,state: 0,sub_divide: 32}"
