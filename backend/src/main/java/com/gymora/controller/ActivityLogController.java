package com.gymora.controller;

import com.gymora.model.dto.request.ActivityLogRequest;
import com.gymora.model.dto.response.ActivityLogResponse;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.service.ActivityLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/activity-logs")
@RequiredArgsConstructor
@Tag(name = "Activity Logs", description = "Activity tracking endpoints")
public class ActivityLogController {

    private final ActivityLogService activityLogService;

    @PostMapping
    @Operation(summary = "Log activity (upserts for same date)")
    public ResponseEntity<ApiResponse<ActivityLogResponse>> logActivity(
            @Valid @RequestBody ActivityLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Activity logged",
                        activityLogService.logActivity(request)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer activity history")
    public ResponseEntity<ApiResponse<List<ActivityLogResponse>>> getCustomerLogs(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(activityLogService.getCustomerLogs(customerId)));
    }

    @GetMapping("/customer/{customerId}/range")
    @Operation(summary = "Get activity logs for date range (for charts)")
    public ResponseEntity<ApiResponse<List<ActivityLogResponse>>> getLogsByDateRange(
            @PathVariable Long customerId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(ApiResponse.success(
                activityLogService.getCustomerLogsByDateRange(customerId, startDate, endDate)));
    }

    @GetMapping("/customer/{customerId}/recent")
    @Operation(summary = "Get last 30 activity logs")
    public ResponseEntity<ApiResponse<List<ActivityLogResponse>>> getRecentLogs(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(activityLogService.getRecentLogs(customerId)));
    }
}
