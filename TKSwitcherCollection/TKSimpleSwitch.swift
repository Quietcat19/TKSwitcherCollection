//
//  TKSimpleSwitch.swift
//  SwitcherCollection
//
//  Created by Tbxark on 15/10/25.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit

@IBDesignable
open class TKSimpleSwitch: TKBaseSwitch {
    private var switchControlLayer = CAShapeLayer()
    private var backgroundLayer = CAShapeLayer()

    // 是否加旋转特效
    @IBInspectable open var rotateWhenValueChange: Bool = false

    @IBInspectable open var onColor: UIColor = UIColor(red: 0.341, green: 0.914, blue: 0.506, alpha: 1) {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var offColor: UIColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var lineColor: UIColor = UIColor(white: 0.8, alpha: 1) {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var circleOnColor: UIColor = UIColor.white {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var circleOffColor: UIColor = UIColor.white {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var circleShadowColor: UIColor = UIColor.clear {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var circleShadowOpacity: Float = 0 {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var circleShadowOffset: CGSize = CGSize.zero {
        didSet {
            resetView()
        }
    }

    @IBInspectable open var lineSize: Double = 10 {
        didSet {
            resetView()
        }
    }

    private var lineWidth: CGFloat {
        return CGFloat(lineSize) * sizeScale
    }

    // 初始化 View
    override internal func setUpView() {
        super.setUpView()
        self.backgroundColor = UIColor.clear
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let radius = bounds.height / 2 - lineWidth
        let roundedRectPath = UIBezierPath(roundedRect: frame.insetBy(dx: lineWidth, dy: lineWidth), cornerRadius: radius)
        backgroundLayer.fillColor = stateToFillColor(false)
        backgroundLayer.strokeColor = lineColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.path = roundedRectPath.cgPath
        layer.addSublayer(backgroundLayer)

        let innerLineWidth = bounds.height - lineWidth * 3 + 1
        let switchControlPath = UIBezierPath()
        switchControlPath.move(to: CGPoint(x: lineWidth, y: 0))
        switchControlPath.addLine(to: CGPoint(x: bounds.width - 2 * lineWidth - innerLineWidth + 1, y: 0))
        var point = backgroundLayer.position
        point.y += (radius + lineWidth)
        point.x += radius
        switchControlLayer.position = point
        switchControlLayer.path = switchControlPath.cgPath
        switchControlLayer.lineCap = CAShapeLayerLineCap.round
        switchControlLayer.fillColor = nil
        switchControlLayer.strokeColor = stateToCircleColor(false)
        switchControlLayer.lineWidth = innerLineWidth
        switchControlLayer.strokeEnd = 0.0001

        switchControlLayer.shadowColor = circleShadowColor.cgColor
        switchControlLayer.shadowOpacity = circleShadowOpacity
        switchControlLayer.shadowOffset = circleShadowOffset

        layer.addSublayer(switchControlLayer)
    }

    // MARK: - Animate

    override func changeValueAnimate(_ value: Bool, duration: Double) {
        let times = [0, 0.49, 0.51, 1]

        // 线条运动动画
        let swichControlStrokeStartAnim = CAKeyframeAnimation(keyPath: "strokeStart")
        swichControlStrokeStartAnim.values = value ? [1, 0, 0, 0] : [0, 0, 0, 1]
        swichControlStrokeStartAnim.keyTimes = times as [NSNumber]?
        swichControlStrokeStartAnim.duration = duration
        swichControlStrokeStartAnim.isRemovedOnCompletion = true

        let swichControlStrokeEndAnim = CAKeyframeAnimation(keyPath: "strokeEnd")
        swichControlStrokeEndAnim.values = value ? [1, 1, 1, 0] : [0, 1, 1, 1]
        swichControlStrokeEndAnim.keyTimes = times as [NSNumber]?
        swichControlStrokeEndAnim.duration = duration
        swichControlStrokeEndAnim.isRemovedOnCompletion = true

        // 颜色动画
        // 背景填充颜色
        let backgroundFillColorAnim = CAKeyframeAnimation(keyPath: "fillColor")
        backgroundFillColorAnim.values = [stateToFillColor(value),
                                          stateToFillColor(value),
                                          stateToFillColor(!value),
                                          stateToFillColor(!value)]
        backgroundFillColorAnim.keyTimes = [0, 0.5, 0.51, 1]
        backgroundFillColorAnim.duration = duration
        backgroundFillColorAnim.fillMode = CAMediaTimingFillMode.forwards
        backgroundFillColorAnim.isRemovedOnCompletion = false
        // 滑块颜色
        let circleColorAnim = CAKeyframeAnimation(keyPath: "strokeColor")
        circleColorAnim.values = [stateToCircleColor(value),
                                  stateToCircleColor(value),
                                  stateToCircleColor(!value),
                                  stateToCircleColor(!value)]
        circleColorAnim.keyTimes = [0, 0.3, 0.31, 1]
        circleColorAnim.duration = duration
        circleColorAnim.fillMode = CAMediaTimingFillMode.forwards
        circleColorAnim.isRemovedOnCompletion = false

        // 旋转动画
        if rotateWhenValueChange {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.transform = self.transform.rotated(by: CGFloat.pi)
            })
        }

        // 动画组
        let swichControlChangeStateAnim = CAAnimationGroup()
        swichControlChangeStateAnim.animations = [swichControlStrokeStartAnim, swichControlStrokeEndAnim, circleColorAnim]
        swichControlChangeStateAnim.fillMode = CAMediaTimingFillMode.forwards
        swichControlChangeStateAnim.isRemovedOnCompletion = false
        swichControlChangeStateAnim.duration = duration

        let animateKey = value ? "value" : "TurnOff"
        switchControlLayer.add(swichControlChangeStateAnim, forKey: animateKey)
        backgroundLayer.add(backgroundFillColorAnim, forKey: "Color")
    }

    private func stateToFillColor(_ isOn: Bool) -> CGColor {
        return isOn ? onColor.cgColor : offColor.cgColor
    }

    private func stateToCircleColor(_ isOn: Bool) -> CGColor {
        return isOn ? circleOnColor.cgColor : circleOffColor.cgColor
    }
}
