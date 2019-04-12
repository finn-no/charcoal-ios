#!/usr/bin/swift

import Foundation

/// Tag management

struct Tag: CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    var description: String {
        return "\(major).\(minor).\(patch)"
    }

    func nextPatch() -> Tag {
        return Tag(major: major, minor: minor, patch: patch + 1)
    }

    func nextMinor() -> Tag {
        return Tag(major: major, minor: minor + 1, patch: 0)
    }

    func nextMajor() -> Tag {
        return Tag(major: major + 1, minor: 0, patch: 0)
    }
}

final class TagManager {
    func loadCurrentTag() -> Tag? {
        let regex = "^[0-9]*\\.[0-9]*\\.[0-9]"
        let gitTag = execute("git tag -l --sort=-v:refname | grep '\(regex)' | head -1 2> /dev/null") ?? ""
        let tag = gitTag.isEmpty ? "0.0.0" : gitTag
        let parts = tag.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".").compactMap({ Int($0) })

        if parts.count == 3 {
            return Tag(major: parts[0], minor: parts[1], patch: parts[2])
        } else {
            return nil
        }
    }

    func createTag(_ tag: Tag, withMessage message: String?) {
        let message = message ?? "\(tag)"
        execute("git tag -a \(tag) -m '\(message)'")
        execute("git push origin \(tag)")
    }

    func deleteTag(_ tag: Tag) {
        execute("git tag -d \(tag)")
        execute("git push origin --delete \(tag)")
    }

    @discardableResult
    private func execute(_ command: String) -> String? {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        return String(data: data, encoding: .utf8)
    }
}

/// Helper functions

func showHelp() {
    print("""
    Automates creation of tags according to Semantic Versioning:

    Commands:   patch | minor | major 'Tagging message'
                current
                delete

    Options:    -f | --force:   don't ask for confirmation
                -m | --message: annotate tag with a message

    Examples:

    Show current version:  version current
    Create patch version:  version patch -m 'Backward compatible bug fixes'
    Create minor version:  version minor --message 'Backward compatible new feature'
    Create major version:  version major -m 'Changes that break backward compatibility'
    Delete last version:   version delete
    """)
}

func performWithConfirmation(_ message: String, force: Bool, closure: () -> Void) {
    guard !force else {
        closure()
        return
    }

    print("\(message) [Y/n]")

    if let response = readLine(), Set(["y", "yes", ""]).contains(response.lowercased()) {
        closure()
        print("Operation succeeded 🎉")
    } else {
        print("Operation cancelled 🚫")
    }
}

/// Command line

let arguments = CommandLine.arguments
let manager = TagManager()

guard arguments.count > 1 else {
    showHelp()
    exit(1)
}

guard let currentTag = manager.loadCurrentTag() else {
    print("The current tag doesn't conform to Semantic Versioning standard MAJOR.MINOR.PATCH")
    exit(1)
}

let action = arguments[1]
let force = arguments.contains(where: { Set(["-f", "--force"]).contains($0) })
var message = arguments.firstIndex(where: { Set(["-m", "--message"]).contains($0) }).flatMap({ index -> String? in
    let nextIndex = index + 1
    return nextIndex < arguments.count ? arguments[nextIndex] : nil
})

var nextTags = [
    "patch": { currentTag.nextPatch() },
    "minor": { currentTag.nextMinor() },
    "major": { currentTag.nextMajor() }
]

switch action {
case "current":
    print("Current tag: \(currentTag)")
case "delete":
    performWithConfirmation("Are you sure you want to delete \(currentTag)?", force: force, closure: {
        manager.deleteTag(currentTag)
    })
default:
    guard let newTag = nextTags[action]?() else {
        showHelp()
        exit(1)
    }

    print("Current tag: \(currentTag)")
    print("New tag: \(newTag)")

    performWithConfirmation("Are you sure you want to create \(newTag)?", force: force, closure: {
        manager.createTag(newTag, withMessage: message)
    })
}

exit(0)
