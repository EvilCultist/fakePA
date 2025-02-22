//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const zap = @import("zap");

fn on_request(r: zap.Request) void {
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
        if (std.mem.eql(u8, the_path, "/")) {
            // r.sendFile("chatbot.html") catch |err| std.log.err()
            if (r.sendFile("src/chatbot.html")) {
                std.debug.print("It worked?\n", .{});
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}", .{err});
            }
        }
    }

    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
    }

    r.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

pub fn main() !void {
    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
        .max_clients = 100000,
    });
    zap.enableDebugLog();
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1, // 1 worker enables sharing state between threads
    });
}
// pub fn main() !void {
//     // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
//     std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
//
//     // stdout is for the actual output of your application, for example if you
//     // are implementing gzip, then only the compressed bytes should be sent to
//     // stdout, not any debugging messages.
//     const stdout_file = std.io.getStdOut().writer();
//     var bw = std.io.bufferedWriter(stdout_file);
//     const stdout = bw.writer();
//
//     try stdout.print("Run `zig build test` to run the tests.\n", .{});
//
//     try bw.flush(); // Don't forget to flush!
// }
//
// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
//
// test "use other module" {
//     try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
// }
//
// test "fuzz example" {
//     const global = struct {
//         fn testOne(input: []const u8) anyerror!void {
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(global.testOne, .{});
// }
//
// const std = @import("std");
//
// /// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
// const lib = @import("fakepa-server_lib");
