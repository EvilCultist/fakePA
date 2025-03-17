//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const zap = @import("zap");
const testing = std.testing;

const Role = enum { user, admin, doctor };

const form_body = struct {
    role: Role,
    content: []const u8,
};

const n_tokens = 0;

pub export fn on_request(r: zap.Request) void {
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
        } else if (std.mem.eql(u8, the_path, "/kanishk-testing")) {
            if (r.sendFile("web/fakenlp.html")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/fakenlp.js")) {
            if (r.sendFile("web/fakenlp.js")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vocab.txt")) {
            if (r.sendFile("web/vocab.txt")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
                std.process.exit(1);
            }
        } else if (std.mem.eql(u8, the_path, "/vectors.txt")) {
            if (r.sendFile("web/vectors.txt")) {
                std.debug.print("It worked?\n", .{});
                return;
            } else |err| {
                std.log.err("oh nards, some error happened\n{any}\n", .{err});
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
