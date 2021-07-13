//
//  String+Extention.swift
//  YDTCUIKit
//
//  Created by 咸宝坤 on 2020/9/25.
//

import Foundation
import UIKit

public extension String {

    /// Left pads string to at least `minWidth` characters wide
    public func leftPad(_ character: Character, toWidth minWidth: Int) -> String {
        guard minWidth > count else { return self }
        return String(repeating: String(character), count: minWidth - count) + self
    }

    public var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil)
        } catch {
            return nil
        }
    }

    public var htmlToString: String? {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    public func httpToHttps() -> String {
        if self.hasPrefix("https") {
            return self
        }
        if self.hasPrefix("http") {
             return replace(start: 0, length: 4, withString: "https")
        }
        return self
    }

    /// URL转义
    public func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }

    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    public subscript(i: Int) -> String {
        let startIndex = index(self.startIndex, offsetBy: i)
        let endIndex = index(startIndex, offsetBy: 1)
        return String(self[startIndex ..< endIndex])
    }

    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    public subscript(r: Range<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = index(self.startIndex, offsetBy: r.upperBound)
        return String(self[startIndex ..< endIndex])
    }

    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    public subscript(index: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: index)
        let endIndex = self.index(startIndex, offsetBy: length)
        return String(self[startIndex ..< endIndex])
    }

    // 截取 从头到i位置
    public func substring(to: Int) -> String {
        return self[0 ..< to]
    }

    // 截取 从i到尾部
    public func substring(from: Int) -> String {
        return self[from ..< self.count]
    }
}

extension String {
    /// 判断是否为空
    public static func isEmpty(_ str: String?) -> Bool {
        if str == nil || NSNull().isEqual(str) {
            return true
        }

        var vStr = str ?? ""
        vStr = vStr.replacingOccurrences(of: " ", with: "")
        if vStr.count == 0 {
            return true
        }

        vStr = vStr.replacingOccurrences(of: "\n", with: "")
        if vStr.count == 0 {
            return true
        }

        vStr = vStr.replacingOccurrences(of: "\r", with: "")
        if vStr.count == 0 {
            return true
        }

        return false
    }

    /// 是否可以显示
    public static func displayEnable(_ str: String?) -> Bool {
        return !String.isEmpty(str) && str != "保密"
    }

    // 大写字母转成小写字母
    public static func changeBigCharacter(chNum: Character) -> Character {
        let chStr = String(chNum)

        var num: UInt32 = 0

        for item in chStr.unicodeScalars {
            num = item.value
        }

        // 如果是大写字母，转换为小写
        if num >= 65 && num <= 90 {
            num += 32
        }

        let newChNum = Character(UnicodeScalar(num)!)

        return newChNum
    }

    // 将字符串中的大写字母转成小写
    public static func changeString(oldString: String) -> String {
        var i = 0

        var newString: String = String()

        while i < oldString.count {
            var ch = oldString[oldString.index(oldString.startIndex, offsetBy: i)]

            ch = String.changeBigCharacter(chNum: ch)

            newString.append(ch)

            i += 1
        }

        return newString
    }

    /** 是否是身份证号
     */
    public func isCardID() -> Bool {
        if count != 18 {
            return false
        }
        let codeArr: [String] = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"]
        let checkCodeDict: [String: String] = ["7": "5", "3": "9", "8": "4", "4": "8", "0": "1", "9": "3", "5": "7", "1": "0", "2": "X", "6": "6", "10": "2"]

        let subString = substring(to: 17)

        let scan: Scanner = Scanner(string: subString)

        var value: Int = 0

        let isNum: Bool = scan.scanInt(&value) && scan.isAtEnd

        if !isNum {
            return false
        }

        var sumValue: Int = 0

        for i in 0 ..< 17 {
            let startIndex = index(self.startIndex, offsetBy: i)
            let endIndex = index(self.startIndex, offsetBy: i + 1)
            sumValue += (Int(self[startIndex ..< endIndex])! * Int(codeArr[i])!)
        }

        let sumValueString = String(sumValue % 11)

        let strlast = checkCodeDict[sumValueString]

        if strlast ==  substring(from: self.count - 1).uppercased() {
            return true
        }
        return false
    }

    /// 判断是否是数字
    public func isInteger() -> Bool {
        let scan = Scanner(string: self)

        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }

    /// 截取字符串
    public func substring(start: Int, length: Int) -> String {
        let start = index(startIndex, offsetBy: start)
        let end = index(start, offsetBy: length)

        return String(self[start ..< end])
    }

    /// 替换字符串
    public func replace(start: Int, length: Int, withString: String) -> String {
        let start = index(startIndex, offsetBy: start)
        let end = index(start, offsetBy: length)

        return replacingCharacters(in: start ..< end, with: withString)
    }

    /// 格式化秒
    public static func formatDuration(_ duration: Int) -> String {
        let seconds = duration % 60
        let minutes = duration / 60 % 60
        let hour = duration / 3600

        return String(format: "%02d:%02d:%02d", hour, minutes, seconds)
    }

    // MARK: 验证合法性相关

    /** 验证是否是手机号码
     */
    public func isMobilePhone() -> Bool {
        if count != 11 {
            return false
        }

        let mobileReg = "^1[2|3|4|5|6|7|8|9]\\d{9}$"

        let regextestMobile = NSPredicate(format: "SELF MATCHES %@", mobileReg)

        return regextestMobile.evaluate(with: self)
    }

    /// 验证是否是微信号
    public func isWeChatID() -> Bool {
        let mobileReg = "^[a-zA-Z]{1}[-_a-zA-Z0-9]{5,19}+$"

        let regextestMobile = NSPredicate(format: "SELF MATCHES %@", mobileReg)

        return regextestMobile.evaluate(with: self)
    }

    // MARK: 计算字符串相关

    /** 获取字符串所占位置大小
     *@param font 字符串要显示的字体
     *@param width 每行最大宽度
     *@return 字符串大小
     */
    public func stringSizeWithFontContainWidth(font: UIFont, width: CGFloat) -> CGSize {
        var size: CGSize = CGSize.zero

        let containSize: CGSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

        size = NSString(string: self).boundingRect(with: containSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil).size

        return size
    }

    // 使用正则表达式替换
    public func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)

        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSRange(location: 0, length: count),
                                              withTemplate: with)
    }

    /// 判断是否数字字母汉子空格
    public var isInputRuleAndBlan: Bool {
        let pattern = "^[a-zA-Z\\u4E00-\\u9FA5\\d\\s]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch = pred.evaluate(with: self)
        return isMatch
    }

    //字符串是否全部是汉字
    public var isAllChineseCharacters: Bool {
        let pattern = "^[\\u4e00-\\u9fa5]+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }

    //图片转换圆角URL
    public var getCircleUrl: String {
        var str = self
        if str.contains("@") {
            str = str.components(separatedBy: "@")[0]
        }
        if self.contains("?") {
            str.append("&x-oss-process=image/circle,r_400/format,png")
        } else {
            str.append("?x-oss-process=image/circle,r_400/format,png")
        }
        return str
    }
}

extension String {
    public init?(gbkData: Data) {
        //获取GBK编码, 使用GB18030是因为它向下兼容GBK
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        //从GBK编码的Data里初始化NSString, 返回的NSString是UTF-16编码
        if let str = NSString(data: gbkData, encoding: encoding) {
            self = str as String
        } else {
            return nil
        }
    }

    public var gbkData: Data {
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        let gbkData = (self as NSString).data(using: encoding)!
        return gbkData
    }

    public func getStringLength(font: UIFont, height: CGFloat) -> CGFloat {
        let statusLabelText: NSString = self as NSString
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return strSize.width
    }

    public func getStringHeight(font: UIFont, width: CGFloat) -> CGFloat {
        let statusLabelText: NSString = self as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return strSize.height
    }
}

extension Optional {
    public var orNil: String {
        if self == nil {
            return "nil"
        }
        if "\(Wrapped.self)" == "String" {
            return "\(self!)"
        }
        return "\(self!)"
    }
}

