	•	watch 用在 UI 想根据状态变化更新 的地方
	•	read 用在 做动作（调用方法）但 UI 不需要刷新 的地方


StatelessWidget：没有内部状态，只根据外部参数来渲染。
StatefulWidget：需要内部保存随时间变化的数据（state）。｜所谓状态的价值就是，后续行为的结果和当前状态有关。
Widget 本身永远不可变，变的是 State。