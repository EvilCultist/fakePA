//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const zap = @import("zap");
const pg = @import("pg");

const a = std.mem.Allocator;
const stdalloc = std.heap.c_allocator;

const tn = struct {
    var name: u8[20] = "";
};

const Role = enum { user, admin, doctor };

const form_body = struct {
    role: Role,
    content: []const u8,
};

const n_tokens = 0;


var pool = try pg.Pool.init(a, .{
  .size = 5,
  .connect = .{
    .port = 5432,
    .host = "127.0.0.1",
  },
  .auth = .{
    .username = "postgres",
    .database = "postgres",
    .timeout = 10_000,
  }
});
defer pool.deinit();

var result = try pool.query("select id, name from users where power > $1", .{9000});
defer result.deinit();

while (try result.next()) |row| {
  const id = row.get(i32, 0);
  // this is only valid until the next call to next(), deinit() or drain()
  const name = row.get([]u8, 1);
}


///json.static.Parsed(main.form_body){
///     .arena = heap.arena_allocator.ArenaAllocator{
///         .child_allocator = mem.Allocator{
///             .ptr = anyopaque@0,
///             .vtable = mem.Allocator.VTable{ ... }
///         },
///         .state = heap.arena_allocator.ArenaAllocator.State{
///             .buffer_list = linked_list.SinglyLinkedList(usize){ ... },
///             .end_index = 0
///         }
///     },
///     .value = main.form_body{
///         .role = main.Role.user,
///         .content = { 110, 111 }
///     }
/// }
fn on_request(r: zap.Request) void {
    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
        return;
    }
    if (r.body) |the_body| {
        std.debug.print("BODY: {s}\n", .{the_body});
        if (std.json.parseFromSlice(
            form_body,
            std.heap.page_allocator,
            the_body,
            .{},
        )) |parsed| {
            std.debug.print("message: {s}\n", .{parsed.value.content});
        } else |err| {
            std.debug.print("no message :( {any}\n", .{err});
        }
        return;
    }
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
        if (std.mem.eql(u8, the_path, "/")) {
            // r.sendFile("chatbot.html") catch |err| std.log.err()
            if (r.sendFile("web/index.html")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "api/addUser")) {
            if (r.sendBody("")) {
                std.debug.print("added user\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "api/addMessage")) {
            if (r.sendBody("")) {
                std.debug.print("added message\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        } else {
            if (r.sendFile("web/404.html")) {
                std.debug.print("added user\n", .{});
                return;
            } else |err| {
                std.debug.print("well see sometimes things happen\n {any}\n", .{err});
                std.process.exit(1);
            }
        }
    }

    unreachable;
}

pub fn main() !void {
    const files: []tn = try a.alloc(stdalloc, tn, 200);
    defer a.free(stdalloc, files);

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
