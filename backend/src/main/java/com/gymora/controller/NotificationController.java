package com.gymora.controller;

import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.entity.Notification;
import com.gymora.model.enums.NotificationType;
import com.gymora.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Notification management endpoints")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user notifications")
    public ResponseEntity<ApiResponse<List<Notification>>> getUserNotifications(
            @PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(
                notificationService.getUserNotifications(userId)));
    }

    @GetMapping("/user/{userId}/unread")
    @Operation(summary = "Get unread notifications")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnreadNotifications(
            @PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(
                notificationService.getUnreadNotifications(userId)));
    }

    @GetMapping("/user/{userId}/unread-count")
    @Operation(summary = "Get unread notification count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(notificationService.getUnreadCount(userId)));
    }

    @PatchMapping("/{id}/read")
    @Operation(summary = "Mark notification as read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.success("Notification marked as read", null));
    }

    @PatchMapping("/user/{userId}/read-all")
    @Operation(summary = "Mark all notifications as read")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(ApiResponse.success("All notifications marked as read", null));
    }

    @PostMapping("/send")
    @PreAuthorize("hasAnyRole('GYM_ADMIN', 'TRAINER', 'SUPER_ADMIN')")
    @Operation(summary = "Send notification to user")
    public ResponseEntity<ApiResponse<Void>> sendNotification(
            @RequestBody Map<String, String> request) {
        notificationService.sendNotification(
                Long.parseLong(request.get("userId")),
                request.get("title"),
                request.get("message"),
                NotificationType.valueOf(request.get("type"))
        );
        return ResponseEntity.ok(ApiResponse.success("Notification sent", null));
    }
}
