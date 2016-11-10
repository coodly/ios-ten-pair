/*
 * Copyright 2015 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public class MoneyFormatter {
    private enum FormatterKey {
        case amountOnlyFormatter
        case currencyFormatter(String)
        
        func key() -> String {
            return String(reflecting: self)
        }
    }
    
    public class func formattedAmountOnly(_ number: NSDecimalNumber) -> String? {
        return amountOnlyFormatter().string(from: number)
    }
    
    public class func formattedAmount(_ number: NSDecimalNumber, currency: String) -> String? {
        return formatterForCurrency(currency).string(from: number)
    }

    private class func amountOnlyFormatter() -> NumberFormatter {
        if let fomatter = MoneyFormatter.formatterForKey(.amountOnlyFormatter) {
            return fomatter
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.currencyDecimalSeparator = "."
        MoneyFormatter.setFormatterForKey(formatter, key: .amountOnlyFormatter)
        
        return formatter
    }
    
    private class func formatterForCurrency(_ currency: String) -> NumberFormatter {
        if let formatter = formatterForKey(.currencyFormatter(currency)) {
            return formatter
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.currencyDecimalSeparator = "."
        MoneyFormatter.setFormatterForKey(formatter, key: .currencyFormatter(currency))
        
        return formatter
    }
    
    private class func setFormatterForKey(_ formatter: NumberFormatter, key: FormatterKey) {
        print(">>>>>>>>>> \(key.key())")
        Thread.current.threadDictionary[key.key()] = formatter
    }
        
    private class func formatterForKey(_ key: FormatterKey) -> NumberFormatter? {
        return Thread.current.threadDictionary[key.key()] as? NumberFormatter
    }
}
