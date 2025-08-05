import Foundation

struct IntervalHelper {
    static func merge(_ intervals: [DateInterval]) -> [DateInterval] {
        let sorted = intervals.sorted { $0.start < $1.start }
        var merged: [DateInterval] = []
        for interval in sorted {
            if let last = merged.last, last.end >= interval.start {
                let newEnd = max(last.end, interval.end)
                merged[merged.count-1] = DateInterval(start: last.start, end: newEnd)
            } else {
                merged.append(interval)
            }
        }
        return merged
    }

    static func invert(_ busy: [DateInterval], within workDay: DateInterval) -> [DateInterval] {
        var free: [DateInterval] = []
        var cursor = workDay.start
        for block in busy {
            if block.start > cursor {
                free.append(DateInterval(start: cursor, end: block.start))
            }
            cursor = max(cursor, block.end)
        }
        if cursor < workDay.end {
            free.append(DateInterval(start: cursor, end: workDay.end))
        }
        return free
    }

    static func intersectAll(_ lists: [[DateInterval]]) -> [DateInterval] {
        guard var result = lists.first else { return [] }
        for list in lists.dropFirst() {
            var next: [DateInterval] = []
            for a in result {
                for b in list {
                    let start = max(a.start, b.start)
                    let end = min(a.end, b.end)
                    if start < end {
                        next.append(DateInterval(start: start, end: end))
                    }
                }
            }
            result = next
        }
        return result
    }
}
