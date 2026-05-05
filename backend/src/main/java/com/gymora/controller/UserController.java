package com.gymora.controller;

import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.UserResponse;
import com.gymora.model.enums.Role;
import com.gymora.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User management endpoints")
public class UserController {

    private final UserService userService;

    @GetMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "List all users (Super Admin only)")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getAllUsers()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUserById(id)));
    }

    @GetMapping("/role/{role}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'GYM_ADMIN')")
    @Operation(summary = "Get users by role")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getUsersByRole(@PathVariable Role role) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUsersByRole(role)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update user profile")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @PathVariable Long id,
            @RequestBody Map<String, String> updates) {
        UserResponse response = userService.updateUser(
                id,
                updates.get("fullName"),
                updates.get("phone"),
                updates.get("avatarUrl")
        );
        return ResponseEntity.ok(ApiResponse.success("User updated", response));
    }

    @PatchMapping("/{id}/fcm-token")
    @Operation(summary = "Update user FCM token")
    public ResponseEntity<ApiResponse<Void>> updateFcmToken(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        userService.updateFcmToken(id, request.get("fcmToken"));
        return ResponseEntity.ok(ApiResponse.success("FCM token updated", null));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Deactivate user (Super Admin only)")
    public ResponseEntity<ApiResponse<Void>> deactivateUser(@PathVariable Long id) {
        userService.deactivateUser(id);
        return ResponseEntity.ok(ApiResponse.success("User deactivated", null));
    }
}
